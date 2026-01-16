import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/dimensions.dart';
import '../widgets/common/neumorphic_container.dart';
import '../models/batch.dart';

/// Batch card widget for displaying batch information
/// Shows batch name, timing, days, coach, enrollment count, and status
class BatchCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewStudents;
  final int? currentEnrollment; // Optional: current number of enrolled students
  final String? status; // Optional: batch status (e.g., "active", "inactive")

  const BatchCard({
    super.key,
    required this.batch,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewStudents,
    this.currentEnrollment,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = onEdit != null || onDelete != null || onViewStudents != null;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          batch.timeRange,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasActions)
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  color: AppColors.cardBackground,
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    } else if (value == 'students' && onViewStudents != null) {
                      onViewStudents!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'Edit',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    if (onViewStudents != null)
                      const PopupMenuItem(
                        value: 'students',
                        child: Text(
                          'View Students',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.calendar_today,
                  label: batch.days.join(', '),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _InfoChip(
                  icon: Icons.person_outline,
                  label: batch.coachName ?? 'No Coach',
                ),
              ),
            ],
          ),
          if (currentEnrollment != null || status != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentEnrollment != null)
                  _EnrollmentBadge(
                    current: currentEnrollment!,
                    capacity: batch.capacity,
                  )
                else
                  const Spacer(),
                if (status != null)
                  _StatusBadge(status: status!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Info chip widget for displaying icon + label
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Enrollment badge showing current/capacity
class _EnrollmentBadge extends StatelessWidget {
  final int current;
  final int capacity;

  const _EnrollmentBadge({
    required this.current,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = capacity > 0 ? (current / capacity) : 0.0;
    final isFull = current >= capacity;
    final isNearFull = percentage >= 0.8;

    Color badgeColor;
    if (isFull) {
      badgeColor = AppColors.error;
    } else if (isNearFull) {
      badgeColor = AppColors.warning;
    } else {
      badgeColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(
          color: badgeColor,
          width: 1,
        ),
      ),
      child: Text(
        '$current/$capacity',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }
}

/// Status badge for batch status
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? AppColors.success : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
