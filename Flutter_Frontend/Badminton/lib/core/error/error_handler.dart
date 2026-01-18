import 'package:dio/dio.dart';

/// Base error class for application errors
abstract class AppError {
  final String message;
  final dynamic originalError;

  AppError(this.message, [this.originalError]);

  @override
  String toString() => message;
}

/// Network error - no internet connection or connection timeout
class NetworkError extends AppError {
  NetworkError([String? message, dynamic originalError])
      : super(message ?? 'Network error. Please check your internet connection.', originalError);
}

/// API error - backend API returned an error response
class ApiError extends AppError {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  ApiError(
    String message,
    this.statusCode,
    this.responseData,
    dynamic originalError,
  ) : super(message, originalError);

  /// Create ApiError from DioException
  factory ApiError.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data is Map<String, dynamic>
        ? error.response!.data as Map<String, dynamic>
        : null;

    String message = 'An error occurred. Please try again.';

    // Try to extract error message from response
    if (responseData != null) {
      if (responseData.containsKey('message')) {
        message = responseData['message'].toString();
      } else if (responseData.containsKey('detail')) {
        message = responseData['detail'].toString();
      } else if (responseData.containsKey('error')) {
        message = responseData['error'].toString();
      }
    }

    // Fallback to status code based messages
    if (message == 'An error occurred. Please try again.') {
      switch (statusCode) {
        case 400:
          message = 'Invalid request. Please check your input.';
          break;
        case 401:
          message = 'Unauthorized. Please login again.';
          break;
        case 403:
          message = 'Access denied. You don\'t have permission to perform this action.';
          break;
        case 404:
          message = 'Resource not found.';
          break;
        case 422:
          message = 'Validation error. Please check your input.';
          break;
        case 500:
          message = 'Server error. Please try again later.';
          break;
        case 503:
          message = 'Service unavailable. Please try again later.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
    }

    return ApiError(message, statusCode, responseData, error);
  }
}

/// Validation error - form validation failed
class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  ValidationError(super.message, [this.fieldErrors, super.originalError]);

  /// Create ValidationError from API response
  factory ValidationError.fromApiResponse(Map<String, dynamic> responseData) {
    final fieldErrors = <String, String>{};
    String message = 'Validation error. Please check your input.';

    // Extract field-level errors
    if (responseData.containsKey('errors') && responseData['errors'] is Map) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          fieldErrors[key] = value.first.toString();
        } else if (value is String) {
          fieldErrors[key] = value;
        }
      });
    }

    // Extract general message
    if (responseData.containsKey('message')) {
      message = responseData['message'].toString();
    } else if (responseData.containsKey('detail')) {
      message = responseData['detail'].toString();
    }

    return ValidationError(message, fieldErrors.isEmpty ? null : fieldErrors);
  }
}

/// Unknown error - unexpected error type
class UnknownError extends AppError {
  UnknownError([String? message, dynamic originalError])
      : super(message ?? 'An unexpected error occurred. Please try again.', originalError);
}

/// Global error handler
class ErrorHandler {
  /// Handle any error and convert to AppError
  static AppError handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is AppError) {
      return error;
    }

    if (error is Exception) {
      final errorString = error.toString();
      
      // Check for network-related errors
      if (errorString.contains('SocketException') ||
          errorString.contains('Network') ||
          errorString.contains('connection')) {
        return NetworkError('Network error. Please check your internet connection.', error);
      }

      // Check for timeout errors
      if (errorString.contains('Timeout') || errorString.contains('timeout')) {
        return NetworkError('Connection timeout. Please try again.', error);
      }

      // Try to extract meaningful message
      if (errorString.contains('Exception: ')) {
        final message = errorString.replaceAll('Exception: ', '');
        return UnknownError(message, error);
      }
    }

    return UnknownError(error.toString(), error);
  }

  /// Handle DioException specifically
  static AppError _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError('Connection timeout. Please try again.', error);

      case DioExceptionType.badResponse:
        // Check if it's a validation error (422)
        if (error.response?.statusCode == 422) {
          final responseData = error.response?.data;
          if (responseData is Map<String, dynamic>) {
            return ValidationError.fromApiResponse(responseData);
          }
        }
        return ApiError.fromDioException(error);

      case DioExceptionType.cancel:
        return UnknownError('Request cancelled.', error);

      case DioExceptionType.unknown:
        // Check if it's a network error
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Network') == true) {
          return NetworkError('Network error. Please check your internet connection.', error);
        }
        return UnknownError('Network error. Please check your connection.', error);

      case DioExceptionType.badCertificate:
        return UnknownError('Certificate error. Please contact support.', error);

      case DioExceptionType.connectionError:
        return NetworkError('Connection error. Please check your internet connection.', error);
    }
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    final appError = handleError(error);
    return appError.message;
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    return handleError(error) is NetworkError;
  }

  /// Check if error is an API error
  static bool isApiError(dynamic error) {
    return handleError(error) is ApiError;
  }

  /// Check if error is a validation error
  static bool isValidationError(dynamic error) {
    return handleError(error) is ValidationError;
  }

  /// Log error (for debugging)
  static void logError(dynamic error, {String? context}) {
    final appError = handleError(error);
    print('${context != null ? '[$context] ' : ''}Error: ${appError.message}');
    if (appError.originalError != null) {
      print('Original error: ${appError.originalError}');
    }
  }
}
