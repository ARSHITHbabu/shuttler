import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/dimensions.dart';
import '../widgets/common/neumorphic_container.dart';
import '../models/student.dart';

/// Student card widget for displaying student information
/// Shows student photo/avatar, name, batch, fee status badge
class StudentCard extends StatelessWidget {
  final Student student;
  final String? batchName;
  final String? feeStatus;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAssignBatch;

  const StudentCard({
    super.key,
    required this.student,
    this.batchName,
    this.feeStatus,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAssignBatch,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = onEdit != null || onDelete != null || onAssignBatch != null;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              _StudentAvatar(
                name: student.name,
                photoUrl: student.profilePhoto,
              ),
              const SizedBox(width: AppDimensions.spacingM),
              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _StatusBadge(status: student.status),
                      ],
                    ),
                    if (student.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              student.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (hasActions)
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  color: AppColors.cardBackground,
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: AppColors.textPrimary),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    if (onAssignBatch != null)
                      const PopupMenuItem(
                        value: 'assign',
                        child: Row(
                          children: [
                            Icon(Icons.group_add, size: 18, color: AppColors.textPrimary),
                            SizedBox(width: 8),
                            Text('Assign Batch', style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'assign' && onAssignBatch != null) {
                      onAssignBatch!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                ),
            ],
          ),
          if (batchName != null || feeStatus != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                if (batchName != null) ...[
                  _InfoChip(
                    icon: Icons.group,
                    label: batchName!,
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                ],
                if (feeStatus != null)
                  _FeeStatusBadge(status: feeStatus!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Student avatar widget with initials fallback
class _StudentAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const _StudentAvatar({
    required this.name,
    this.photoUrl,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.avatarM,
      height: AppDimensions.avatarM,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.2),
        border: Border.all(
          color: AppColors.accent,
          width: 2,
        ),
      ),
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _InitialsAvatar(
                  initials: _getInitials(name),
                ),
              ),
            )
          : _InitialsAvatar(initials: _getInitials(name)),
    );
  }
}

/// Initials avatar widget
class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

/// Status badge for student status
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Fee status badge
class _FeeStatusBadge extends StatelessWidget {
  final String status;

  const _FeeStatusBadge({required this.status});

  Color _getFeeStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'overdue':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getFeeStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.attach_money,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
