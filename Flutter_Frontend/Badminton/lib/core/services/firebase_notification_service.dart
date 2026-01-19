import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'api_service.dart';
import '../constants/api_endpoints.dart';

/// Top-level function for handling background messages
/// Must be top-level or static to be accessible from isolate
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message here
}

/// Service for handling Firebase Cloud Messaging (FCM) notifications
class FirebaseNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final StorageService _storageService;
  final ApiService _apiService;
  
  String? _fcmToken;
  bool _isInitialized = false;

  FirebaseNotificationService({
    required StorageService storageService,
    required ApiService apiService,
  })  : _storageService = storageService,
        _apiService = apiService;

  /// Initialize Firebase Messaging
  Future<void> initialize({
    required int userId,
    required String userType,
    Function(RemoteMessage)? onMessage,
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    if (_isInitialized) return;

    try {
      // Request permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        _fcmToken = await _fcm.getToken();
        
        if (_fcmToken != null) {
          // Save token locally
          await _storageService.saveFcmToken(_fcmToken!);
          
          // Send token to backend
          await _updateFcmTokenOnBackend(userId, userType, _fcmToken!);
        }

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Foreground message received: ${message.messageId}');
          onMessage?.call(message);
          _showNotification(message);
        });

        // Handle background messages when app is opened from notification
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('App opened from notification: ${message.messageId}');
          onMessageOpenedApp?.call(message);
          _handleNotificationTap(message);
        });

        // Check if app was opened from a notification (when app was terminated)
        final initialMessage = await _fcm.getInitialMessage();
        if (initialMessage != null) {
          debugPrint('App opened from terminated state: ${initialMessage.messageId}');
          onMessageOpenedApp?.call(initialMessage);
          _handleNotificationTap(initialMessage);
        }

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // Listen for token refresh
        _fcm.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _storageService.saveFcmToken(newToken);
          _updateFcmTokenOnBackend(userId, userType, newToken);
        });

        _isInitialized = true;
        debugPrint('Firebase Messaging initialized successfully');
      } else {
        debugPrint('Firebase Messaging permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  /// Update FCM token on backend
  Future<void> _updateFcmTokenOnBackend(
    int userId,
    String userType,
    String token,
  ) async {
    try {
      String endpoint;
      if (userType == 'coach') {
        endpoint = '/api/coaches/$userId';
      } else if (userType == 'student') {
        endpoint = '/api/students/$userId';
      } else {
        return; // Owner or unknown type
      }

      await _apiService.put(
        endpoint,
        data: {'fcm_token': token},
      );
    } catch (e) {
      debugPrint('Failed to update FCM token on backend: $e');
    }
  }

  /// Show notification when app is in foreground
  void _showNotification(RemoteMessage message) {
    // In a real app, you might want to use a notification plugin
    // For now, we'll just log it
    debugPrint('Notification: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    
    // You can show an in-app notification banner here
    // For example, using Get.snackbar or a custom notification widget
  }

  /// Handle notification tap and navigate accordingly
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    // Navigation logic based on notification type
    // This would typically use a router or navigator
    switch (type) {
      case 'announcement':
        // Navigate to announcements screen
        debugPrint('Navigate to announcements');
        break;
      case 'fee_due':
        // Navigate to fees screen
        debugPrint('Navigate to fees');
        break;
      case 'attendance':
        // Navigate to attendance screen
        debugPrint('Navigate to attendance');
        break;
      case 'performance':
        // Navigate to performance screen
        debugPrint('Navigate to performance');
        break;
      case 'session':
        // Navigate to schedule screen
        debugPrint('Navigate to schedule');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Unsubscribe from notifications
  Future<void> unsubscribe() async {
    try {
      await _fcm.deleteToken();
      await _storageService.removeFcmToken();
      _fcmToken = null;
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error unsubscribing from notifications: $e');
    }
  }
}
