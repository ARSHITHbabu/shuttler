import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/leave_request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/leave_request.dart';
import '../../widgets/common/custom_text_field.dart';

/// Requests Screen - View and manage leave requests from coaches
class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'
  final TextEditingController _reviewNotesController = TextEditingController();

  @override
  void dispose() {
    _reviewNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build filter parameters
    String? statusFilter;
    if (_selectedFilter != 'all') {
      statusFilter = _selectedFilter;
    }

    final leaveRequestsAsync = ref.watch(
      leaveRequestManagerProvider(
        coachId: null,
        status: statusFilter,
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Leave Requests',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(isDark),

          // Leave Requests List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  leaveRequestManagerProvider(
                    coachId: null,
                    status: statusFilter,
                  ),
                );
              },
              child: leaveRequestsAsync.when(
                loading: () => const ListSkeleton(itemCount: 5),
                error: (error, stack) => ErrorDisplay(
                  message: 'Failed to load leave requests: ${error.toString()}',
                  onRetry: () => ref.invalidate(
                    leaveRequestManagerProvider(
                      coachId: null,
                      status: statusFilter,
                    ),
                  ),
                ),
                data: (requests) {
                  if (requests.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  // Sort: pending first, then by submission date
                  final sortedRequests = List<LeaveRequest>.from(requests)
                    ..sort((a, b) {
                      if (a.isPending && !b.isPending) return -1;
                      if (!a.isPending && b.isPending) return 1;
                      return b.submittedAt.compareTo(a.submittedAt);
                    });

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: sortedRequests.length,
                    itemBuilder: (context, index) {
                      final request = sortedRequests[index];
                      return _buildLeaveRequestCard(request, isDark);
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
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Wrap(
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingS,
            children: ['all', 'pending', 'approved', 'rejected'].map((status) {
              final isSelected = _selectedFilter == status;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = status),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.spacingS,
                  ),
                  color: isSelected
                      ? (isDark ? AppColors.accent : AppColorsLight.accent)
                      : (isDark ? AppColors.cardBackground : AppColorsLight.cardBackground),
                  borderRadius: AppDimensions.radiusS,
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? AppColors.background : AppColorsLight.background)
                          : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'No Leave Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              _selectedFilter == 'all'
                  ? 'No leave requests have been submitted yet'
                  : 'No ${_selectedFilter} leave requests',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request, bool isDark) {
    final statusColor = _getStatusColor(request.status, isDark);
    final statusBgColor = statusColor.withValues(alpha: 0.1);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Coach name and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.coachName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.leaveTypeLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Date range
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                '${DateFormat('MMM dd, yyyy').format(request.startDate)} - ${DateFormat('MMM dd, yyyy').format(request.endDate)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),

          // Duration
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                '${request.endDate.difference(request.startDate).inDays + 1} day(s)',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Reason
          Text(
            'Reason:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            request.reason,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),

          // Review notes (if reviewed)
          if (request.reviewNotes != null && request.reviewNotes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardBackground.withValues(alpha: 0.5)
                    : AppColorsLight.cardBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Notes:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.reviewNotes!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Submitted date
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Submitted: ${DateFormat('MMM dd, yyyy • hh:mm a').format(request.submittedAt)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
            ),
          ),

          // Action buttons (only for pending requests)
          if (request.isPending) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _rejectRequest(request),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                ElevatedButton(
                  onPressed: () => _approveRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    }
  }

  Future<void> _approveRequest(LeaveRequest request) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Approve Leave Request',
      'Are you sure you want to approve this leave request?',
      confirmText: 'Approve',
      cancelText: 'Cancel',
      icon: Icons.check_circle_outline,
    );

    if (confirmed == true && mounted) {
      await _showReviewNotesDialog(request, isApproval: true);
    }
  }

  Future<void> _rejectRequest(LeaveRequest request) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Reject Leave Request',
      'Are you sure you want to reject this leave request?',
      confirmText: 'Reject',
      cancelText: 'Cancel',
      icon: Icons.cancel_outlined,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await _showReviewNotesDialog(request, isApproval: false);
    }
  }

  Future<void> _showReviewNotesDialog(LeaveRequest request, {required bool isApproval}) async {
    _reviewNotesController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardBackground
            : AppColorsLight.cardBackground,
        title: Text(
          isApproval ? 'Approve Leave Request' : 'Reject Leave Request',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        content: CustomTextField(
          controller: _reviewNotesController,
          label: 'Review Notes (Optional)',
          hint: 'Add any notes about this decision...',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : AppColorsLight.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproval ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final authState = await ref.read(authProvider.future);
        if (authState is Authenticated && authState.userType == 'owner') {
          final manager = ref.read(
            leaveRequestManagerProvider(
              coachId: null,
              status: _selectedFilter == 'all' ? null : _selectedFilter,
            ).notifier,
          );

          await manager.updateLeaveRequestStatus(
            requestId: request.id,
            ownerId: authState.userId,
            status: isApproval ? 'approved' : 'rejected',
            reviewNotes: _reviewNotesController.text.trim().isEmpty
                ? null
                : _reviewNotesController.text.trim(),
          );

          // Invalidate to refresh the list
          ref.invalidate(
            leaveRequestManagerProvider(
              coachId: null,
              status: _selectedFilter == 'all' ? null : _selectedFilter,
            ),
          );

          if (mounted) {
            SuccessSnackbar.show(
              context,
              'Leave request ${isApproval ? 'approved' : 'rejected'} successfully',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(
            context,
            'Failed to ${isApproval ? 'approve' : 'reject'} leave request: ${e.toString()}',
          );
        }
      }
    }
  }
}
