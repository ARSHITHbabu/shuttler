import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching API responses offline
class OfflineCacheService {
  static const String _cachePrefix = 'offline_cache_';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  static const Duration _defaultCacheDuration = Duration(hours: 24);

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialize the cache service
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Cache API response
  Future<void> cacheResponse({
    required String key,
    required dynamic data,
    Duration? cacheDuration,
  }) async {
    if (!_isInitialized) await init();

    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_cacheTimestampPrefix$key';
    
    final jsonData = jsonEncode(data);
    final expiryTime = DateTime.now().add(cacheDuration ?? _defaultCacheDuration);

    await _prefs!.setString(cacheKey, jsonData);
    await _prefs!.setString(timestampKey, expiryTime.toIso8601String());
  }

  /// Get cached response if available and not expired
  T? getCachedResponse<T>(String key) {
    if (!_isInitialized) return null;

    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_cacheTimestampPrefix$key';

    final cachedData = _prefs!.getString(cacheKey);
    final expiryString = _prefs!.getString(timestampKey);

    if (cachedData == null || expiryString == null) {
      return null;
    }

    try {
      final expiryTime = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiryTime)) {
        // Cache expired, remove it
        _prefs!.remove(cacheKey);
        _prefs!.remove(timestampKey);
        return null;
      }

      final decoded = jsonDecode(cachedData);
      return decoded as T?;
    } catch (e) {
      // Invalid cache data, remove it
      _prefs!.remove(cacheKey);
      _prefs!.remove(timestampKey);
      return null;
    }
  }

  /// Check if cached response exists and is valid
  bool hasValidCache(String key) {
    if (!_isInitialized) return false;

    final timestampKey = '$_cacheTimestampPrefix$key';
    final expiryString = _prefs!.getString(timestampKey);

    if (expiryString == null) return false;

    try {
      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      return false;
    }
  }

  /// Clear specific cache entry
  Future<void> clearCache(String key) async {
    if (!_isInitialized) await init();

    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_cacheTimestampPrefix$key';

    await _prefs!.remove(cacheKey);
    await _prefs!.remove(timestampKey);
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    if (!_isInitialized) await init();

    final keys = _prefs!.getKeys();
    final cacheKeys = keys.where((key) => 
      key.startsWith(_cachePrefix) || key.startsWith(_cacheTimestampPrefix)
    );

    for (final key in cacheKeys) {
      await _prefs!.remove(key);
    }
  }

  /// Get cache size (number of cached entries)
  int getCacheSize() {
    if (!_isInitialized) return 0;

    final keys = _prefs!.getKeys();
    return keys.where((key) => key.startsWith(_cachePrefix)).length;
  }
}
