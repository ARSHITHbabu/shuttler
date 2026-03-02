import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import 'neumorphic_button.dart';

/// Error display widget with retry button
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? retryButtonText;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppDimensions.spacingL),
                NeumorphicButton(
                  text: retryButtonText ?? 'Retry',
                  onPressed: onRetry,
                  icon: Icons.refresh,
                  isAccent: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget with variants for different screens
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final String? title;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.title,
  });

  /// Empty state for students list
  factory EmptyState.noStudents({VoidCallback? onAdd}) {
    return EmptyState(
      title: 'No Students Yet',
      message: 'Start by adding your first student to the academy.',
      icon: Icons.person_outline,
      actionText: 'Add Student',
      onAction: onAdd,
    );
  }

  /// Empty state for inactive students
  factory EmptyState.noInactiveStudents() {
    return const EmptyState(
      title: 'No Inactive Students',
      message: '',
      icon: Icons.person_outline,
    );
  }

  /// Empty state for batches list
  factory EmptyState.noBatches({VoidCallback? onCreate}) {
    return EmptyState(
      title: 'No Batches Created',
      message: 'Create your first batch to organize training sessions.',
      icon: Icons.group_outlined,
      actionText: 'Create Batch',
      onAction: onCreate,
    );
  }

  /// Empty state for inactive batches
  factory EmptyState.noInactiveBatches() {
    return const EmptyState(
      title: 'No Inactive Batches',
      message: 'All your batches are currently active.',
      icon: Icons.archive_outlined,
    );
  }

  /// Empty state for attendance records
  factory EmptyState.noAttendance({VoidCallback? onMark}) {
    return EmptyState(
      title: 'No Attendance Records',
      message: 'Mark attendance for today to get started.',
      icon: Icons.check_circle_outline,
      actionText: 'Mark Attendance',
      onAction: onMark,
    );
  }

  /// Empty state for fees
  factory EmptyState.noFees() {
    return EmptyState(
      title: 'No Fee Records',
      message: 'Fee records will appear here once created.',
      icon: Icons.payment_outlined,
    );
  }

  /// Empty state for notifications
  factory EmptyState.noNotifications() {
    return EmptyState(
      title: 'No Notifications',
      message: 'You\'re all caught up! No new notifications.',
      icon: Icons.notifications_none,
    );
  }

  /// Empty state for events
  factory EmptyState.noEvents({VoidCallback? onAdd}) {
    return EmptyState(
      title: 'No Events',
      message: 'Add holidays, tournaments, or events to your calendar.',
      icon: Icons.event_outlined,
      actionText: 'Add Event',
      onAction: onAdd,
    );
  }

  /// Empty state for announcements
  factory EmptyState.noAnnouncements({VoidCallback? onCreate}) {
    return EmptyState(
      title: 'No Announcements',
      message: 'Create an announcement to notify students and coaches.',
      icon: Icons.announcement_outlined,
      actionText: 'Create Announcement',
      onAction: onCreate,
    );
  }

  /// Empty state for performance records
  factory EmptyState.noPerformance() {
    return EmptyState(
      title: 'No Performance Records',
      message: 'Performance tracking records will appear here.',
      icon: Icons.trending_up_outlined,
    );
  }

  /// Empty state for BMI records
  factory EmptyState.noBmiRecords() {
    return EmptyState(
      title: 'No BMI Records',
      message: 'BMI tracking records will appear here.',
      icon: Icons.monitor_weight_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              if (title != null) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: AppDimensions.spacingL),
                NeumorphicButton(
                  text: actionText!,
                  onPressed: onAction,
                  isAccent: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Network error widget
class NetworkError extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkError({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      message: 'No internet connection.\nPlease check your network and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}
