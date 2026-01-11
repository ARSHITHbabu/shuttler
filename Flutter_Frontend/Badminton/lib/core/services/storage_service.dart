import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for persisting user data
class StorageService {
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserType = 'user_type';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyFcmToken = 'fcm_token';

  late SharedPreferences _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Token
  Future<bool> saveAuthToken(String token) async {
    return await _prefs.setString(_keyAuthToken, token);
  }

  String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }

  Future<bool> removeAuthToken() async {
    return await _prefs.remove(_keyAuthToken);
  }

  // User ID
  Future<bool> saveUserId(int userId) async {
    return await _prefs.setInt(_keyUserId, userId);
  }

  int? getUserId() {
    return _prefs.getInt(_keyUserId);
  }

  Future<bool> removeUserId() async {
    return await _prefs.remove(_keyUserId);
  }

  // User Type (owner/coach/student)
  Future<bool> saveUserType(String userType) async {
    return await _prefs.setString(_keyUserType, userType);
  }

  String? getUserType() {
    return _prefs.getString(_keyUserType);
  }

  Future<bool> removeUserType() async {
    return await _prefs.remove(_keyUserType);
  }

  // User Email
  Future<bool> saveUserEmail(String email) async {
    return await _prefs.setString(_keyUserEmail, email);
  }

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  Future<bool> removeUserEmail() async {
    return await _prefs.remove(_keyUserEmail);
  }

  // User Name
  Future<bool> saveUserName(String name) async {
    return await _prefs.setString(_keyUserName, name);
  }

  String? getUserName() {
    return _prefs.getString(_keyUserName);
  }

  Future<bool> removeUserName() async {
    return await _prefs.remove(_keyUserName);
  }

  // Remember Me
  Future<bool> saveRememberMe(bool value) async {
    return await _prefs.setBool(_keyRememberMe, value);
  }

  bool getRememberMe() {
    return _prefs.getBool(_keyRememberMe) ?? false;
  }

  // FCM Token (for push notifications)
  Future<bool> saveFcmToken(String token) async {
    return await _prefs.setString(_keyFcmToken, token);
  }

  String? getFcmToken() {
    return _prefs.getString(_keyFcmToken);
  }

  Future<bool> removeFcmToken() async {
    return await _prefs.remove(_keyFcmToken);
  }

  // Clear all user data (logout)
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // Clear only auth data (keep app preferences)
  Future<void> clearAuthData() async {
    await removeAuthToken();
    await removeUserId();
    await removeUserType();
    await removeUserEmail();
    await removeUserName();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get all user data as map
  Map<String, dynamic> getUserData() {
    return {
      'token': getAuthToken(),
      'userId': getUserId(),
      'userType': getUserType(),
      'email': getUserEmail(),
      'name': getUserName(),
      'fcmToken': getFcmToken(),
    };
  }
}
