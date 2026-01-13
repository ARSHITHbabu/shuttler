import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/colors.dart';
import '../core/constants/dimensions.dart';
import '../widgets/common/neumorphic_container.dart';

/// Notification card widget
/// Displays notification with icon, title, body, timestamp
/// Different styles for read/unread
class NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final IconData? icon;
  final String? type; // 'fee_due', 'attendance', 'announcement', 'general'
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.icon,
    this.type,
    this.onTap,
    this.onDelete,
  });

  IconData _getIconForType() {
    if (icon != null) return icon!;
    
    switch (type?.toLowerCase()) {
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

  Color _getColorForType() {
    switch (type?.toLowerCase()) {
      case 'fee_due':
        return AppColors.warning;
      case 'attendance':
        return AppColors.success;
      case 'announcement':
        return AppColors.info;
      default:
        return AppColors.accent;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForType();
    final backgroundColor = isRead
        ? AppColors.cardBackground
        : AppColors.cardBackground.withValues(alpha: 0.8);

    return Dismissible(
      key: Key('notification_${timestamp.millisecondsSinceEpoch}'),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        color: backgroundColor,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                _getIconForType(),
                size: 20,
                color: iconColor,
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
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    _formatTimestamp(timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
