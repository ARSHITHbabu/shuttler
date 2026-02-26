import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local storage service for persisting user data
class StorageService {
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserType = 'user_type';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';
  static const String _keyMustChangePassword = 'must_change_password';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyFcmToken = 'fcm_token';
  
  // Academy Details
  static const String _keyAcademyName = 'academy_name';
  static const String _keyAcademyAddress = 'academy_address';
  static const String _keyAcademyContact = 'academy_contact';
  static const String _keyAcademyEmail = 'academy_email';

  SharedPreferences? _prefs;
  final _secureStorage = const FlutterSecureStorage();
  
  String? _cachedAuthToken;
  String? _cachedRefreshToken;
  String? _cachedFcmToken;

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
    
    // Migrate credentials from SharedPreferences if they exist
    final oldAuth = _prefs!.getString(_keyAuthToken);
    final oldFcm = _prefs!.getString(_keyFcmToken);
    
    if (oldAuth != null) {
      await _secureStorage.write(key: _keyAuthToken, value: oldAuth);
      await _prefs!.remove(_keyAuthToken);
    }
    if (oldFcm != null) {
      await _secureStorage.write(key: _keyFcmToken, value: oldFcm);
      await _prefs!.remove(_keyFcmToken);
    }
    
    _cachedAuthToken = await _secureStorage.read(key: _keyAuthToken);
    _cachedRefreshToken = await _secureStorage.read(key: _keyRefreshToken);
    _cachedFcmToken = await _secureStorage.read(key: _keyFcmToken);

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
    await _secureStorage.write(key: _keyAuthToken, value: token);
    _cachedAuthToken = token;
    return true;
  }

  String? getAuthToken() {
    if (!_isInitialized) {
      // Return null if not initialized (safe for read operations)
      return null;
    }
    return _cachedAuthToken;
  }

  Future<bool> removeAuthToken() async {
    await _ensureInitialized();
    await _secureStorage.delete(key: _keyAuthToken);
    _cachedAuthToken = null;
    return true;
  }

  // Refresh Token
  Future<bool> saveRefreshToken(String token) async {
    await _ensureInitialized();
    await _secureStorage.write(key: _keyRefreshToken, value: token);
    _cachedRefreshToken = token;
    return true;
  }

  String? getRefreshToken() {
    if (!_isInitialized) {
      return null;
    }
    return _cachedRefreshToken;
  }

  Future<bool> removeRefreshToken() async {
    await _ensureInitialized();
    await _secureStorage.delete(key: _keyRefreshToken);
    _cachedRefreshToken = null;
    return true;
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
  
  // User Role (owner/co_owner)
  Future<bool> saveUserRole(String role) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyUserRole, role);
  }

  String? getUserRole() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyUserRole);
  }

  Future<bool> removeUserRole() async {
    await _ensureInitialized();
    return await _prefs!.remove(_keyUserRole);
  }

  // Must Change Password
  Future<bool> saveMustChangePassword(bool value) async {
    await _ensureInitialized();
    return await _prefs!.setBool(_keyMustChangePassword, value);
  }

  bool getMustChangePassword() {
    if (!_isInitialized) return false;
    return _prefs!.getBool(_keyMustChangePassword) ?? false;
  }

  Future<bool> removeMustChangePassword() async {
    await _ensureInitialized();
    return await _prefs!.remove(_keyMustChangePassword);
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
    await _secureStorage.write(key: _keyFcmToken, value: token);
    _cachedFcmToken = token;
    return true;
  }

  String? getFcmToken() {
    if (!_isInitialized) return null;
    return _cachedFcmToken;
  }

  Future<bool> removeFcmToken() async {
    await _ensureInitialized();
    await _secureStorage.delete(key: _keyFcmToken);
    _cachedFcmToken = null;
    return true;
  }

  // Clear all user data (logout)
  Future<bool> clearAll() async {
    await _ensureInitialized();
    return await _prefs!.clear();
  }

  // Clear only auth data (keep app preferences)
  Future<void> clearAuthData() async {
    await removeAuthToken();
    await removeRefreshToken();
    await removeUserId();
    await removeUserType();
    await removeUserEmail();
    await removeUserName();
    await removeUserRole();
    await removeMustChangePassword();
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
      'role': getUserRole(),
      'mustChangePassword': getMustChangePassword(),
      'fcmToken': getFcmToken(),
    };
  }

  // Academy Details
  Future<bool> saveAcademyName(String name) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyAcademyName, name);
  }

  String? getAcademyName() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyAcademyName);
  }

  Future<bool> saveAcademyAddress(String address) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyAcademyAddress, address);
  }

  String? getAcademyAddress() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyAcademyAddress);
  }

  Future<bool> saveAcademyContact(String contact) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyAcademyContact, contact);
  }

  String? getAcademyContact() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyAcademyContact);
  }

  Future<bool> saveAcademyEmail(String email) async {
    await _ensureInitialized();
    return await _prefs!.setString(_keyAcademyEmail, email);
  }

  String? getAcademyEmail() {
    if (!_isInitialized) return null;
    return _prefs!.getString(_keyAcademyEmail);
  }

  // Generic string getter/setter for app preferences (like theme)
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs!.getString(key);
  }
}
