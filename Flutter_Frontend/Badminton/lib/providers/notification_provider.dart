import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/notification.dart';
import 'service_providers.dart';

part 'notification_provider.g.dart';

/// Provider for notification list
@riverpod
Future<List<Notification>> notificationList(
  NotificationListRef ref,
  int userId,
  String userType, {
  String? type,
  bool? isRead,
}) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getNotifications(
    userId: userId,
    userType: userType,
    type: type,
    isRead: isRead,
  );
}

/// Provider for unread notification count
@riverpod
Future<int> unreadCount(
  UnreadCountRef ref,
  int userId,
  String userType,
) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getUnreadCount(
    userId: userId,
    userType: userType,
  );
}

/// Provider for notifications by type
@riverpod
Future<List<Notification>> notificationByType(
  NotificationByTypeRef ref,
  int userId,
  String userType,
  String type,
) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getNotifications(
    userId: userId,
    userType: userType,
    type: type,
  );
}

/// Provider for notification by ID
@riverpod
Future<Notification> notificationById(NotificationByIdRef ref, int id) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getNotificationById(id);
}

/// Provider class for notification operations
@riverpod
class NotificationManager extends _$NotificationManager {
  @override
  Future<List<Notification>> build({
    required int userId,
    required String userType,
    String? type,
    bool? isRead,
  }) async {
    final notificationService = ref.watch(notificationServiceProvider);
    return notificationService.getNotifications(
      userId: userId,
      userType: userType,
      type: type,
      isRead: isRead,
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(int id) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markAsRead(id);
      
      // Invalidate related providers
      ref.invalidate(notificationByIdProvider(id));
      ref.invalidate(unreadCountProvider(userId, userType));
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark multiple notifications as read
  Future<void> markAllAsRead(List<int> ids) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markAllAsRead(ids);
      
      // Invalidate related providers
      ref.invalidate(unreadCountProvider(userId, userType));
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int id) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.deleteNotification(id);
      
      // Invalidate related providers
      ref.invalidate(notificationByIdProvider(id));
      ref.invalidate(unreadCountProvider(userId, userType));
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Refresh notification list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final notificationService = ref.read(notificationServiceProvider);
      return notificationService.getNotifications(
        userId: userId,
        userType: userType,
      );
    });
  }
}
