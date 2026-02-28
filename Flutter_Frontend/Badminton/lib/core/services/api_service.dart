import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';
import '../network/request_queue.dart';
import '../network/connectivity_service.dart';

/// API service for making HTTP requests to the backend
class ApiService {
  late final Dio _dio;
  final StorageService _storageService;
  RequestQueue? _requestQueue;
  ConnectivityService? _connectivityService;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());

    _setupCertificatePinning();
  }

  /// Sets up SSL Certificate Pinning for better security (Phase E4)
  void _setupCertificatePinning() {
    if (kIsWeb) return; // Not applicable for web

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // By disabling default trusted roots, all cert checks fall through to badCertificateCallback
        final context = SecurityContext(withTrustedRoots: false);
        final client = HttpClient(context: context);

        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // You should only pin against your known backend domain
          // Example: if (host != 'api.shuttler.app') return false;

          final bytes = cert.der;
          final digest = sha256.convert(bytes);
          final fingerprint = digest.toString().toUpperCase().replaceAll(':', '');

          // Replace with real SHA-256 hashes generated from the live SSL certificate
          // OpenSSL command to get the pin:
          // openssl s_client -servername api.example.com -connect api.example.com:443 < /dev/null 2>/dev/null | openssl x509 -in /dev/stdin -outform der | openssl dgst -sha256 -hex
          const primaryPin = 'PRIMARY_CERT_SHA256_HASH_HERE';

          // KEEP A BACKUP PIN. Rotate securely by changing the backend cert, validating with the backup, 
          // and pushing an app update exchanging the backup out.
          const backupPin = 'BACKUP_CERT_SHA256_HASH_HERE';

          // For local development, automatically accept localhost certificates
          if (host == '10.0.2.2' || host == '127.0.0.1' || host == 'localhost') {
            return true;
          }

          return fingerprint == primaryPin || fingerprint == backupPin;
        };

        return client;
      },
    );
  }

  /// Initialize offline support with RequestQueue
  void initializeOfflineSupport({
    required ConnectivityService connectivityService,
  }) {
    _connectivityService = connectivityService;
    _requestQueue = RequestQueue(
      connectivityService: connectivityService,
      dio: _dio,
    );
  }

  /// Auth interceptor - adds token to requests
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = _storageService.getAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }

  /// Logging interceptor - logs requests and responses (debug only)
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🌐 REQUEST[${options.method}] => ${options.path}');
        if (options.data != null) {
          print('📤 Data: ${options.data}');
        }
        if (options.queryParameters.isNotEmpty) {
          print('🔍 Params: ${options.queryParameters}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}');
        print('💥 Message: ${error.message}');
        handler.next(error);
      },
    );
  }

  /// Error interceptor - handles common errors
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        // Handle 401 Unauthorized - token expired
        if (error.response?.statusCode == 401) {
          final refreshToken = _storageService.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              // Use a separate Dio instance to avoid interceptor loop
              final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
              final refreshResponse = await refreshDio.post(
                '/auth/refresh',
                data: {'refresh_token': refreshToken},
                options: Options(
                  headers: {'Content-Type': 'application/json'},
                ),
              );

              if (refreshResponse.statusCode == 200) {
                final data = refreshResponse.data;
                final newAccessToken = data['access_token'];
                final newRefreshToken = data['refresh_token'];

                if (newAccessToken != null) {
                  await _storageService.saveAuthToken(newAccessToken);
                  if (newRefreshToken != null) {
                    await _storageService.saveRefreshToken(newRefreshToken);
                  }

                  // Retry the original request with the new token
                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newAccessToken';
                  
                  // Use a separate Dio instance to retry the request without triggering interceptors again
                  final retryDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
                  final cloneReq = await retryDio.fetch(options);
                  return handler.resolve(cloneReq);
                }
              }
            } catch (e) {
              print('🔒 Token refresh failed: $e');
            }
          }

          print('🔒 Unauthorized - clearing auth data');
          try {
            await _storageService.clearAuthData();
          } catch (e) {
            print('⚠️ Failed to clear auth data: $e');
          }
          // The router/app state will detect clearAuthData and redirect to login
        }

        // Handle network errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          print('⏱️ Timeout error');
        }

        if (error.type == DioExceptionType.unknown) {
          print('📡 Network error - check connection');
        }

        handler.next(error);
      },
    );
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      // Use RequestQueue if available and offline
      if (_requestQueue != null) {
        final isConnected = await _connectivityService!.isConnected();
        if (!isConnected) {
          // Queue the request for later execution
          return await _requestQueue!.queueRequest(
            method: 'GET',
            path: path,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // If request fails and we have RequestQueue, try queuing it
      if (_requestQueue != null && e is DioException) {
        if (e.type == DioExceptionType.unknown || 
            e.type == DioExceptionType.connectionTimeout) {
          return await _requestQueue!.queueRequest(
            method: 'GET',
            path: path,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      // Use RequestQueue if available and offline
      if (_requestQueue != null) {
        final isConnected = await _connectivityService!.isConnected();
        if (!isConnected) {
          // Queue the request for later execution
          return await _requestQueue!.queueRequest(
            method: 'POST',
            path: path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // If request fails and we have RequestQueue, try queuing it
      if (_requestQueue != null && e is DioException) {
        if (e.type == DioExceptionType.unknown || 
            e.type == DioExceptionType.connectionTimeout) {
          return await _requestQueue!.queueRequest(
            method: 'POST',
            path: path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      // Use RequestQueue if available and offline
      if (_requestQueue != null) {
        final isConnected = await _connectivityService!.isConnected();
        if (!isConnected) {
          // Queue the request for later execution
          return await _requestQueue!.queueRequest(
            method: 'PUT',
            path: path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // If request fails and we have RequestQueue, try queuing it
      if (_requestQueue != null && e is DioException) {
        if (e.type == DioExceptionType.unknown || 
            e.type == DioExceptionType.connectionTimeout) {
          return await _requestQueue!.queueRequest(
            method: 'PUT',
            path: path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      rethrow;
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      // Use RequestQueue if available and offline
      if (_requestQueue != null) {
        final isConnected = await _connectivityService!.isConnected();
        if (!isConnected) {
          // Queue the request for later execution
          return await _requestQueue!.queueRequest(
            method: 'PATCH',
            path: path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // If request fails and we have RequestQueue, try queuing it
      if (_requestQueue != null && e is DioException) {
        if (e.type == DioExceptionType.unknown || 
            e.type == DioExceptionType.connectionTimeout) {
          return await _requestQueue!.queueRequest(
            method: 'PATCH',
            path: path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    try {
      // Use RequestQueue if available and offline
      if (_requestQueue != null) {
        final isConnected = await _connectivityService!.isConnected();
        if (!isConnected) {
          // Queue the request for later execution
          return await _requestQueue!.queueRequest(
            method: 'DELETE',
            path: path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // If request fails and we have RequestQueue, try queuing it
      if (_requestQueue != null && e is DioException) {
        if (e.type == DioExceptionType.unknown || 
            e.type == DioExceptionType.connectionTimeout) {
          return await _requestQueue!.queueRequest(
            method: 'DELETE',
            path: path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            priority: priority,
          );
        }
      }
      rethrow;
    }
  }

  /// Upload file (multipart/form-data)
  /// Supports both file paths (mobile/desktop) and bytes (web)
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      MultipartFile multipartFile;
      
      // Check if we're on web platform
      try {
        // Try to use fromFile first (works on mobile/desktop)
        multipartFile = await MultipartFile.fromFile(filePath);
      } catch (e) {
        // If fromFile fails (e.g., on web), this method should not be called
        // Instead, use uploadFileBytes for web
        rethrow;
      }

      final formData = FormData.fromMap({
        fieldName: multipartFile,
        ...?additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload file from bytes (for web support)
  Future<Response> uploadFileBytes(
    String path,
    Uint8List bytes,
    String filename, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: MultipartFile.fromBytes(bytes, filename: filename),
        ...?additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload image file (convenience method for profile images)
  /// Returns the image URL from the response
  Future<String> uploadImage(String filePath) async {
    try {
      final response = await uploadFile(
        ApiEndpoints.uploadImage,
        filePath,
        fieldName: 'file',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('url')) {
          // Return full URL
          final url = data['url'] as String;
          if (url.startsWith('http')) {
            return url;
          } else {
            // Prepend base URL if relative
            return '${ApiEndpoints.baseUrl}$url';
          }
        }
      }
      throw Exception('Failed to upload image: Invalid response');
    } catch (e) {
      rethrow;
    }
  }

  /// Upload image from bytes (for web support)
  /// Returns the image URL from the response
  Future<String> uploadImageBytes(Uint8List bytes, {String filename = 'image.jpg'}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dio.post(
        ApiEndpoints.uploadImage,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('url')) {
          // Return full URL
          final url = data['url'] as String;
          if (url.startsWith('http')) {
            return url;
          } else {
            // Prepend base URL if relative
            return '${ApiEndpoints.baseUrl}$url';
          }
        }
      }
      throw Exception('Failed to upload image: Invalid response');
    } catch (e) {
      rethrow;
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Handle API errors and return user-friendly messages
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please try again.';
        case DioExceptionType.badResponse:
          return _parseErrorResponse(error.response);
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        case DioExceptionType.unknown:
          return 'Network error. Please check your connection.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return error.toString();
  }

  /// Parse error response from backend
  String _parseErrorResponse(Response? response) {
    if (response == null) return 'Unknown error occurred.';

    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        // Check for common error message fields
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
      }
    } catch (e) {
      print('Error parsing error response: $e');
    }

    // Return status code message
    return 'Error ${response.statusCode}: ${response.statusMessage ?? "Unknown error"}';
  }

  /// Get queue size (for offline requests)
  int get queueSize => _requestQueue?.queueSize ?? 0;

  /// Clear request queue
  void clearQueue() {
    _requestQueue?.clearQueue();
  }

  /// Dispose resources
  void dispose() {
    _requestQueue?.dispose();
  }
}
