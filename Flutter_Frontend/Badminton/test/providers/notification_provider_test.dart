import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/models/notification.dart';

/// Basic unit tests for notification provider logic
void main() {
  group('Notification Provider Logic Tests', () {
    test('Unread count calculation works correctly', () {
      // Arrange
      final notifications = [
        Notification(
          id: 1,
          userId: 1,
          userType: 'student',
          title: 'Test 1',
          body: 'Body 1',
          type: 'general',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        Notification(
          id: 2,
          userId: 1,
          userType: 'student',
          title: 'Test 2',
          body: 'Body 2',
          type: 'general',
          isRead: true,
          createdAt: DateTime.now(),
        ),
        Notification(
          id: 3,
          userId: 1,
          userType: 'student',
          title: 'Test 3',
          body: 'Body 3',
          type: 'general',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ];

      // Act
      final unreadCount = notifications.where((n) => !n.isRead).length;

      // Assert
      expect(unreadCount, 2);
    });

    test('Notification filtering by type works correctly', () {
      // Arrange
      final notifications = [
        Notification(
          id: 1,
          userId: 1,
          userType: 'student',
          title: 'Fee Due',
          body: 'Your fee is due',
          type: 'fee_due',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        Notification(
          id: 2,
          userId: 1,
          userType: 'student',
          title: 'Announcement',
          body: 'New announcement',
          type: 'announcement',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ];

      // Act
      final feeNotifications = notifications.where((n) => n.type == 'fee_due').toList();

      // Assert
      expect(feeNotifications.length, 1);
      expect(feeNotifications.first.title, 'Fee Due');
    });
  });
}
