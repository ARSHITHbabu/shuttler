import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification.dart';
import '../student/student_announcements_screen.dart';
import '../coach/coach_announcements_screen.dart';
import '../owner/announcement_management_screen.dart';
import '../student/student_fees_screen.dart';
import '../student/student_schedule_screen.dart';
import '../coach/leave_request_screen.dart';
import '../owner/requests_screen.dart';

/// Notifications Screen - View and manage notifications
class NotificationsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const NotificationsScreen({super.key, this.onBack});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'all'; // 'all', 'fee_due', 'attendance', 'announcement', 'general'
  String _readFilter = 'all'; // 'all', 'read', 'unread'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authStateAsync = ref.watch(authProvider);

    return authStateAsync.when(
      data: (authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
            body: Center(
              child: Text(
                'Please log in to view notifications',
                style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
              ),
            ),
          );
        }

        return _buildNotificationsScreen(authState, isDark);
      },
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: ListSkeleton(itemCount: 5)),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: ErrorDisplay(
          message: 'Failed to load user data: ${error.toString()}',
          onRetry: () => ref.invalidate(authProvider),
        ),
      ),
    );
  }

  Widget _buildNotificationsScreen(Authenticated authState, bool isDark) {
    // Build filter parameters
    String? typeFilter;
    if (_selectedFilter != 'all') {
      typeFilter = _selectedFilter;
    }

    bool? isReadFilter;
    if (_readFilter == 'read') {
      isReadFilter = true;
    } else if (_readFilter == 'unread') {
      isReadFilter = false;
    }

    final notificationsAsync = ref.watch(notificationManagerProvider(
      userId: authState.userId,
      userType: authState.userType,
      type: typeFilter,
      isRead: isReadFilter,
    ));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle_outline, color: isDark ? AppColors.accent : AppColorsLight.accent),
            tooltip: 'Mark all as read',
            onPressed: () => _markAllAsRead(authState),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(isDark),
          
          // Notifications List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationManagerProvider(
                  userId: authState.userId,
                  userType: authState.userType,
                  type: typeFilter,
                  isRead: isReadFilter,
                ));
              },
              child: notificationsAsync.when(
                loading: () => const ListSkeleton(itemCount: 5),
                error: (error, stack) => ErrorDisplay(
                  message: 'Failed to load notifications: ${error.toString()}',
                  onRetry: () => ref.invalidate(notificationManagerProvider(
                    userId: authState.userId,
                    userType: authState.userType,
                    type: typeFilter,
                    isRead: isReadFilter,
                  )),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return EmptyState.noNotifications();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        isDark: isDark,
                        onTap: () => _handleNotificationTap(notification, authState),
                        onDelete: () => _deleteNotification(notification),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    final accent = isDark ? AppColors.accent : AppColorsLight.accent;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL,
        vertical: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Type',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['all', 'fee_due', 'attendance', 'announcement', 'general'].map((type) {
                final isSelected = _selectedFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacingM),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                        vertical: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? accent : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? accent : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        type == 'all' ? 'All' : type.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? bg : textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: AppDimensions.spacingL),
          Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['all', 'unread', 'read'].map((status) {
                final isSelected = _readFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacingM),
                  child: GestureDetector(
                    onTap: () => setState(() => _readFilter = status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                        vertical: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? accent : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? accent : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status == 'all' ? 'All' : status.toUpperCase(),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? bg : textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(Notification notification, Authenticated authState) async {
    // 1. Mark as read
    if (!notification.isRead) {
      try {
        final notificationManager = ref.read(notificationManagerProvider(
          userId: authState.userId,
          userType: authState.userType,
        ).notifier);
        
        await notificationManager.markAsRead(notification.id);
      } catch (e) {
        // Silently fail marking as read, still navigate
        debugPrint('Failed to mark as read: $e');
      }
    }

    if (!mounted) return;

    // 2. Navigate based on type and user role
    final data = notification.data ?? {};
    
    // Announcement Navigation
    if (notification.type == 'announcement') {
      if (authState.userType == 'student') {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const StudentAnnouncementsScreen(),
        ));
      } else if (authState.userType == 'coach') {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const CoachAnnouncementsScreen(),
        ));
      } else if (authState.userType == 'owner') {
        // Owner view (using existing management screen)
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const AnnouncementManagementScreen(),
        ));
      }
    }
    // Fee Due Navigation
    else if (notification.type == 'fee_due') {
      if (authState.userType == 'student') {
         Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const StudentFeesScreen(),
        ));
      }
    }
    // Attendance/Schedule Navigation
    else if (notification.type == 'attendance' || data.containsKey('batch_id')) {
      if (authState.userType == 'student') {
         Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const StudentScheduleScreen(),
        ));
      }
    }
    // Leave Requests Navigation
    else if (data.containsKey('leave_request_id')) {
      if (authState.userType == 'coach') {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const LeaveRequestScreen(),
        ));
      } else if (authState.userType == 'owner') {
         // Assuming RequestsScreen handles tabs for leave requests
         Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const RequestsScreen(),
        ));
      }
    }
    // Registration Request Navigation (Owner)
    else if (data.containsKey('registration_request_id') && authState.userType == 'owner') {
       Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const RequestsScreen(),
       ));
    }
  }

  Future<void> _markAllAsRead(Authenticated authState) async {
    try {
      final notificationsAsync = ref.read(notificationManagerProvider(
        userId: authState.userId,
        userType: authState.userType,
      ));
      
      final notifications = notificationsAsync.valueOrNull ?? [];
      final unreadIds = notifications
          .where((n) => !n.isRead)
          .map((n) => n.id)
          .toList();

      if (unreadIds.isEmpty) {
        if (mounted) {
          SuccessSnackbar.showInfo(context, 'All notifications are already read');
        }
        return;
      }

      final notificationManager = ref.read(notificationManagerProvider(
        userId: authState.userId,
        userType: authState.userType,
      ).notifier);
      
      await notificationManager.markAllAsRead(unreadIds);
      
      if (mounted) {
        SuccessSnackbar.show(context, 'All notifications marked as read');
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to mark all as read: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteNotification(Notification notification) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Delete Notification',
      'Are you sure you want to delete this notification?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_outline,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      try {
        final authState = await ref.read(authProvider.future);
        if (authState is Authenticated) {
          final notificationManager = ref.read(notificationManagerProvider(
            userId: authState.userId,
            userType: authState.userType,
          ).notifier);
          
          await notificationManager.deleteNotification(notification.id);
          
          if (mounted) {
            SuccessSnackbar.show(context, 'Notification deleted successfully');
          }
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Failed to delete notification: ${e.toString()}');
        }
      }
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final Notification notification;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'fee_due':
        return Icons.attach_money;
      case 'attendance':
        return Icons.check_circle;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'fee_due':
        return isDark ? AppColors.error : AppColorsLight.error;
      case 'attendance':
        return isDark ? AppColors.success : AppColorsLight.success;
      case 'announcement':
        return isDark ? AppColors.warning : AppColorsLight.warning;
      default:
        return isDark ? AppColors.accent : AppColorsLight.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final timeAgo = _formatTimeAgo(notification.createdAt);
    final iconColor = _getColorForType(notification.type);
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final textTertiary = isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;
    final accent = isDark ? AppColors.accent : AppColorsLight.accent;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              _getIconForType(notification.type),
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: textTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: textTertiary,
            onPressed: onDelete,
            tooltip: 'Delete notification',
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, y').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
