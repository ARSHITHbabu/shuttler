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
    required String userType,
    bool rememberMe = false,
  }) async {
    try {
      // Determine endpoint based on user type
      // Each user type has its own login endpoint
      String endpoint;
      if (userType == 'owner') {
        endpoint = ApiEndpoints.ownerLogin;  // /owners/login
      } else if (userType == 'coach') {
        endpoint = '/coaches/login';
      } else {
        endpoint = '/students/login';
      }

      final response = await _apiService.post(
        endpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if login was successful
        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Login failed');
        }

        // Extract user data from nested object based on user type
        Map<String, dynamic>? userData;
        if (userType == 'student') {
          userData = data['student'];
        } else if (userType == 'owner') {
          userData = data['owner'];
        } else {
          userData = data['coach'];
        }

        if (userData == null) {
          throw Exception('Invalid response format');
        }

        // Create session token
        final sessionToken = 'session-${userData['id']}';

        // Save auth data
        await _storageService.saveAuthToken(sessionToken);
        await _storageService.saveUserId(userData['id']);
        await _storageService.saveUserType(userType);
        await _storageService.saveUserEmail(email);
        await _storageService.saveUserName(userData['name']);
        await _storageService.saveRememberMe(rememberMe);

        // Return user data with profile completeness for students
        final Map<String, dynamic> result = {'user': userData};
        if (userType == 'student') {
          // Check profile completeness from backend response or student data
          bool profileComplete = false;
          
          // First check if backend explicitly returns profile_complete (at top level)
          if (data.containsKey('profile_complete')) {
            final profileCompleteValue = data['profile_complete'];
            // Handle both boolean and string representations
            profileComplete = profileCompleteValue == true || 
                            profileCompleteValue == 'true' ||
                            profileCompleteValue == 1;
          }
          
          // If not found in response, check required profile fields from student data
          if (!profileComplete) {
            // Required fields: guardian_name, guardian_phone, date_of_birth, address, t_shirt_size
            final guardianName = userData['guardian_name'];
            final guardianPhone = userData['guardian_phone'];
            final dateOfBirth = userData['date_of_birth'];
            final address = userData['address'];
            final tShirtSize = userData['t_shirt_size'];
            
            profileComplete = guardianName != null &&
                guardianName.toString().trim().isNotEmpty &&
                guardianPhone != null &&
                guardianPhone.toString().trim().isNotEmpty &&
                dateOfBirth != null &&
                dateOfBirth.toString().trim().isNotEmpty &&
                address != null &&
                address.toString().trim().isNotEmpty &&
                tShirtSize != null &&
                tShirtSize.toString().trim().isNotEmpty;
          }
          
          // If still not complete, try fetching student profile directly as fallback
          if (!profileComplete && userData['id'] != null) {
            try {
              final studentId = userData['id'] as int;
              final studentResponse = await _apiService.get(
                ApiEndpoints.studentById(studentId),
              );
              
              if (studentResponse.statusCode == 200) {
                final studentProfile = studentResponse.data;
                final guardianName = studentProfile['guardian_name'];
                final guardianPhone = studentProfile['guardian_phone'];
                final dateOfBirth = studentProfile['date_of_birth'];
                final address = studentProfile['address'];
                final tShirtSize = studentProfile['t_shirt_size'];
                
                profileComplete = guardianName != null &&
                    guardianName.toString().trim().isNotEmpty &&
                    guardianPhone != null &&
                    guardianPhone.toString().trim().isNotEmpty &&
                    dateOfBirth != null &&
                    dateOfBirth.toString().trim().isNotEmpty &&
                    address != null &&
                    address.toString().trim().isNotEmpty &&
                    tShirtSize != null &&
                    tShirtSize.toString().trim().isNotEmpty;
              }
            } catch (e) {
              // If fetch fails, use the value we already determined
              // This prevents blocking login if profile endpoint is unavailable
            }
          }
          
          result['profile_complete'] = profileComplete;
        }
        return result;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
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
