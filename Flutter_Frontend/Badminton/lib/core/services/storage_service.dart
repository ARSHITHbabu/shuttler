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

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  Future<void>? _initFuture;
  
  /// Check if storage is initialized (for external checks)
  bool get isInitialized => _isInitialized;

  /// Initialize the storage service
  Future<void> init() async {
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;
    
    _initFuture = _doInit();
    await _initFuture;
  }

  Future<void> _doInit() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Ensure storage is initialized (for web compatibility)
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// Synchronously check if initialized, and if not, try to initialize
  /// This is a best-effort approach for sync methods
  void _tryInitSync() {
    if (!_isInitialized && _prefs == null) {
      // For web, SharedPreferences.getInstance() might work synchronously
      // This is a fallback - ideally storage should be initialized in main()
      try {
        // Try to get instance synchronously (may not work on all platforms)
        SharedPreferences.getInstance().then((prefs) {
          _prefs = prefs;
          _isInitialized = true;
        }).catchError((_) {});
      } catch (_) {
        // If sync init fails, we'll return null/false from getters
      }
    }
  }

  // Auth Token
  Future<bool> saveAuthToken(String token) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyAuthToken, token);
  }

  String? getAuthToken() {
    if (!_isInitialized) {
      // Return null if not initialized (safe for read operations)
      return null;
    }
    return _prefs!.getString(_keyAuthToken);
  }

  Future<bool> removeAuthToken() async {
    await _ensureInitialized();
    return await _prefs!.remove(_keyAuthToken);
  }

  // User ID
  Future<bool> saveUserId(int userId) async {
    await _ensureInitialized();
    return await _prefs!.setInt(_keyUserId, userId);
  }

  int? getUserId() {
    // Try to initialize if not already initialized (best effort for sync method)
    if (!_isInitialized) {
      _tryInitSync();
    }
    
    if (!_isInitialized) {
      return null;
    }
    return _prefs!.getInt(_keyUserId);
  }

  Future<bool> removeUserId() async {
    await _ensureInitialized();
    return await _prefs!.remove(_keyUserId);
  }

  // User Type (owner/coach/student)
  Future<bool> saveUserType(String userType) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyUserType, userType);
  }

  String? getUserType() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyUserType);
  }

  Future<bool> removeUserType() async {
    await _ensureInitialized();
    return await _prefs!.remove(_keyUserType);
  }

  // User Email
  Future<bool> saveUserEmail(String email) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyUserEmail, email);
  }

  String? getUserEmail() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyUserEmail);
  }

  Future<bool> removeUserEmail() async {
    await _ensureInitialized();
    return await _prefs!.remove(_keyUserEmail);
  }

  // User Name
  Future<bool> saveUserName(String name) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyUserName, name);
  }

  String? getUserName() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyUserName);
  }

  Future<bool> removeUserName() async {
    await _ensureInitialized();
    return await _prefs!.remove(_keyUserName);
  }

  // Remember Me
  Future<bool> saveRememberMe(bool value) async {
    await _ensureInitialized();
    return await _prefs!.setBool(_keyRememberMe, value);
  }

  bool getRememberMe() {
    if (!_isInitialized) return false;
    return _prefs!.getBool(_keyRememberMe) ?? false;
  }

  // FCM Token (for push notifications)
  Future<bool> saveFcmToken(String token) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyFcmToken, token);
  }

  String? getFcmToken() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyFcmToken);
  }

  Future<bool> removeFcmToken() async {
    await _ensureInitialized();
    return await _prefs!.remove(_keyFcmToken);
  }

  // Clear all user data (logout)
  Future<bool> clearAll() async {
    await _ensureInitialized();
    return await _prefs!.clear();
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
    // Try to initialize if not already initialized (best effort for sync method)
    if (!_isInitialized) {
      _tryInitSync();
    }
    
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
