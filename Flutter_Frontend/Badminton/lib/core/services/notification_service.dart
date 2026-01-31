import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/notification.dart';

/// Service for notification-related API operations
class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  /// Get notifications for a user
  Future<List<Notification>> getNotifications({
    required int userId,
    required String userType,
    String? type,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) {
        queryParams['type'] = type;
      }
      if (isRead != null) {
        queryParams['is_read'] = isRead;
      }

      final response = await _apiService.get(
        ApiEndpoints.userNotifications(userId, userType),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch notifications: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get notification by ID
  Future<Notification> getNotificationById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.notificationById(id));
      return Notification.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch notification: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int id) async {
    try {
      await _apiService.put(ApiEndpoints.markNotificationRead(id));
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Mark multiple notifications as read
  Future<void> markAllAsRead(List<int> ids) async {
    try {
      for (final id in ids) {
        await markAsRead(id);
      }
    } catch (e) {
      throw Exception('Failed to mark notifications as read: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get unread count for a user
  Future<int> getUnreadCount({
    required int userId,
    required String userType,
  }) async {
    try {
      final notifications = await getNotifications(
        userId: userId,
        userType: userType,
        isRead: false,
      );
      return notifications.length;
    } catch (e) {
      throw Exception('Failed to get unread count: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.notificationById(id));
    } catch (e) {
      throw Exception('Failed to delete notification: ${_apiService.getErrorMessage(e)}');
    }
  }
}
