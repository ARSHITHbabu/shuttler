import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Authentication service for login, logout, and session management
class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

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
      // Owner uses coach login endpoint (owner is admin coach)
      String endpoint;
      if (userType == 'coach' || userType == 'owner') {
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

        // Extract user data from nested object
        final userData = userType == 'student' 
            ? data['student'] 
            : data['coach'];

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

        return {'user': userData};
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
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
      String endpoint;
      if (userType == 'coach' || userType == 'owner') {
        endpoint = ApiEndpoints.coaches;
      } else {
        endpoint = ApiEndpoints.students;
      }

      // Prepare data based on user type
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      };

      // Add role field for coaches/owners
      if (userType == 'coach' || userType == 'owner') {
        requestData['role'] = userType;  // Set role to "owner" or "coach"
      }

      // Add any additional data
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
        final userData = data['coach'] ?? data['student'] ?? data;

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
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
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
      if (userType == 'coach') {
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
      if (userType == 'coach') {
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
      if (userType == 'coach') {
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
