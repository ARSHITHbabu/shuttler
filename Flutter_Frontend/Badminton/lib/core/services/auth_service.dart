import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Authentication service for login, logout, and session management
class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  /// Get user-friendly error message from exception
  String getUserFriendlyErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection and try again.';
        case DioExceptionType.badResponse:
          final response = error.response;
          if (response != null && response.data != null) {
            final data = response.data;
            if (data is Map<String, dynamic>) {
              // Check for backend error messages
              if (data.containsKey('message')) {
                return data['message'].toString();
              }
              if (data.containsKey('detail')) {
                return data['detail'].toString();
              }
              if (data.containsKey('error')) {
                return data['error'].toString();
              }
            }
          }
          // HTTP status code based messages
          switch (error.response?.statusCode) {
            case 400:
              return 'Invalid request. Please check your input.';
            case 401:
              return 'Invalid email or password. Please try again.';
            case 403:
              return 'Access denied. Please contact support.';
            case 404:
              return 'Service not found. Please try again later.';
            case 500:
              return 'Server error. Please try again later.';
            default:
              return 'An error occurred. Please try again.';
          }
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        case DioExceptionType.unknown:
          return 'Network error. Please check your internet connection.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    
    // Handle string exceptions
    final errorString = error.toString();
    if (errorString.contains('Exception: ')) {
      return errorString.replaceAll('Exception: ', '');
    }
    if (errorString.contains('Login failed')) {
      return 'Invalid email or password. Please try again.';
    }
    if (errorString.contains('Network')) {
      return 'Network error. Please check your internet connection.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Login with email and password
  /// Returns user data on success
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final userType = data['userType'] as String;
          final userData = data['user'] as Map<String, dynamic>;

          // Save common data
          await _storageService.saveAuthToken('dummy_token'); // Backend doesn't return JWT yet
          await _storageService.saveUserId(userData['id']);
          await _storageService.saveUserType(userType);
          await _storageService.saveUserEmail(userData['email']);
          await _storageService.saveUserName(userData['name']);

          // Save role-specific data for owners
          if (userType == 'owner') {
            await _storageService.saveUserRole(userData['role'] ?? 'owner');
            await _storageService.saveMustChangePassword(userData['must_change_password'] ?? false);
          }

          return data;
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        final message = e.response?.data['detail'] ?? e.message;
        throw Exception(message);
      }
      rethrow;
    }
  }

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Determine endpoint based on user type
      // Each user type has its own separate endpoint and table
      String endpoint;
      if (userType == 'owner') {
        endpoint = ApiEndpoints.owners;  // /owners/
      } else if (userType == 'coach') {
        endpoint = ApiEndpoints.coaches;  // /coaches/
      } else {
        endpoint = ApiEndpoints.students;  // /students/
      }

      // Prepare data based on user type
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      };

      // Add any additional data (specialization, experience_years, etc.)
      if (additionalData != null) {
        requestData.addAll(additionalData);
      }

      final response = await _apiService.post(
        endpoint,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Registration returns user data directly (not nested like login)
        // But handle both cases just in case
        final userData = data['owner'] ?? data['coach'] ?? data['student'] ?? data;

        if (userData['id'] == null) {
          throw Exception('Invalid response format');
        }

        // Auto-login after successful registration
        final sessionToken = 'session-${userData['id']}';
        await _storageService.saveAuthToken(sessionToken);
        await _storageService.saveUserId(userData['id']);
        await _storageService.saveUserType(userType);
        await _storageService.saveUserEmail(email);
        await _storageService.saveUserName(userData['name']);
        await _storageService.saveRememberMe(false);

        return {'user': userData};
      } else {
        throw Exception('Registration failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      // Clear all stored auth data
      await _storageService.clearAuthData();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _storageService.isLoggedIn();
  }

  /// Get current user ID
  int? getCurrentUserId() {
    return _storageService.getUserId();
  }

  /// Get current user type
  String? getCurrentUserType() {
    return _storageService.getUserType();
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return _storageService.getUserEmail();
  }

  /// Get current user name
  String? getCurrentUserName() {
    return _storageService.getUserName();
  }

  /// Get current user role (for owners)
  String? getUserRole() {
    return _storageService.getUserRole();
  }

  /// Get must change password flag
  bool getMustChangePassword() {
    return _storageService.getMustChangePassword();
  }

  /// Get auth token
  String? getAuthToken() {
    return _storageService.getAuthToken();
  }

  /// Validate token (check if expired)
  Future<bool> validateToken() async {
    try {
      final token = getAuthToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // Try to fetch user profile to validate token
      final userId = getCurrentUserId();
      final userType = getCurrentUserType();

      if (userId == null || userType == null) {
        return false;
      }

      // Make a simple API call to verify token
      String endpoint;
      if (userType == 'owner') {
        endpoint = ApiEndpoints.ownerById(userId);
      } else if (userType == 'coach') {
        endpoint = ApiEndpoints.coachById(userId);
      } else {
        endpoint = ApiEndpoints.studentById(userId);
      }

      final response = await _apiService.get(endpoint);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Refresh user data from backend
  Future<Map<String, dynamic>> refreshUserData() async {
    try {
      final userId = getCurrentUserId();
      final userType = getCurrentUserType();

      if (userId == null || userType == null) {
        throw Exception('User not logged in');
      }

      String endpoint;
      if (userType == 'owner') {
        endpoint = ApiEndpoints.ownerById(userId);
      } else if (userType == 'coach') {
        endpoint = ApiEndpoints.coachById(userId);
      } else {
        endpoint = ApiEndpoints.studentById(userId);
      }

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data;

        // Update stored user data
        await _storageService.saveUserName(data['name']);
        await _storageService.saveUserEmail(data['email']);
        
        // Update owner-specific fields
        if (userType == 'owner') {
          if (data.containsKey('role')) {
            await _storageService.saveUserRole(data['role']);
          }
          if (data.containsKey('must_change_password')) {
            await _storageService.saveMustChangePassword(data['must_change_password'] == true);
          }
        }

        return data;
      } else {
        throw Exception('Failed to refresh user data');
      }
    } catch (e) {
      throw Exception('Failed to refresh user data: ${e.toString()}');
    }
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final userId = getCurrentUserId();
      final userType = getCurrentUserType();

      if (userId == null || userType == null) {
        return;
      }

      // Save token locally
      await _storageService.saveFcmToken(fcmToken);

      // Update token on backend
      String endpoint;
      if (userType == 'owner') {
        endpoint = ApiEndpoints.ownerById(userId);
      } else if (userType == 'coach') {
        endpoint = ApiEndpoints.coachById(userId);
      } else {
        endpoint = ApiEndpoints.studentById(userId);
      }

      await _apiService.put(
        endpoint,
        data: {'fcm_token': fcmToken},
      );
    } catch (e) {
      print('Failed to update FCM token: $e');
    }
  }

  /// Get user data as map
  Map<String, dynamic> getUserData() {
    return _storageService.getUserData();
  }
}
