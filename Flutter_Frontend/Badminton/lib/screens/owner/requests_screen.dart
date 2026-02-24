import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../providers/leave_request_provider.dart';
import '../../providers/student_registration_request_provider.dart';
import '../../providers/coach_registration_request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/pending_invitations_provider.dart';
import '../../models/leave_request.dart';
import '../../models/student_registration_request.dart';
import '../../models/coach_registration_request.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';

/// Requests Screen - View and manage leave requests and student registration requests
class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'
  final TextEditingController _reviewNotesController = TextEditingController();
  final TextEditingController _registrationReviewNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Update UI when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewNotesController.dispose();
    _registrationReviewNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

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
          'Requests',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL,
              vertical: isSmallScreen ? 6 : AppDimensions.spacingM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNeumorphicTab(
                    isDark: isDark,
                    label: 'Leave Requests',
                    icon: Icons.event_busy_outlined,
                    isSelected: _tabController.index == 0,
                    onTap: () {
                      if (_tabController.index != 0) {
                        _tabController.animateTo(0);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _buildNeumorphicTab(
                    isDark: isDark,
                    label: 'Registrations',
                    icon: Icons.person_add_outlined,
                    isSelected: _tabController.index == 1,
                    onTap: () {
                      if (_tabController.index != 1) {
                        _tabController.animateTo(1);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _buildNeumorphicTab(
                    isDark: isDark,
                    label: 'Rejoin Requests',
                    icon: Icons.person_pin_outlined,
                    isSelected: _tabController.index == 2,
                    onTap: () {
                      if (_tabController.index != 2) {
                        _tabController.animateTo(2);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveRequestsTab(isDark, statusFilter, isSmallScreen),
          _buildRegistrationRequestsTab(isDark, statusFilter, isSmallScreen),
          _buildRejoinRequestsTab(isDark, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildNeumorphicTab({
    required bool isDark,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cardColor = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;
    final activeColor = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final inactiveColor = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? AppDimensions.paddingS : AppDimensions.paddingM,
          vertical: isSmallScreen ? 6 : AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isSelected ? NeumorphicStyles.getPressedShadow() : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 16 : 18,
              color: isSelected ? activeColor : inactiveColor,
            ),
            if (!isVerySmallScreen) ...[  
              SizedBox(width: isSmallScreen ? 4 : AppDimensions.spacingS),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingS : AppDimensions.paddingM),
      margin: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : AppDimensions.spacingS),
          Wrap(
            spacing: isSmallScreen ? 6 : AppDimensions.spacingS,
            runSpacing: isSmallScreen ? 6 : AppDimensions.spacingS,
            children: ['all', 'pending', 'approved', 'rejected'].map((status) {
              final isSelected = _selectedFilter == status;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = status),
                child: NeumorphicContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : AppDimensions.paddingM,
                    vertical: isSmallScreen ? 6 : AppDimensions.spacingS,
                  ),
                  color: isSelected
                      ? (isDark ? AppColors.accent : AppColorsLight.accent)
                      : (isDark ? AppColors.cardBackground : AppColorsLight.cardBackground),
                  borderRadius: AppDimensions.radiusS,
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
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


  Widget _buildLeaveRequestCard(LeaveRequest request, bool isDark, bool isSmallScreen) {
    final statusColor = _getStatusColor(request.status, isDark);
    final statusBgColor = statusColor.withValues(alpha: 0.1);

    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingM),
      margin: EdgeInsets.only(bottom: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
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
                        fontSize: isSmallScreen ? 16 : 18,
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
                NeumorphicButton(
                  text: 'Reject',
                  icon: Icons.close,
                  onPressed: () => _rejectRequest(request),
                  isOutlined: true,
                  color: AppColors.error,
                  textColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                NeumorphicButton(
                  text: 'Approve',
                  icon: Icons.check,
                  onPressed: () => _approveRequest(request),
                  color: AppColors.success,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
              ],
            ),
          ],

          // History Section
          if (request.originalStartDate != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Original: ${DateFormat('dd MMM').format(request.originalStartDate!)} - ${DateFormat('dd MMM').format(request.originalEndDate!)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Modification Request Section
          if (request.hasPendingModification) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_calendar, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Modification Request", 
                        style: TextStyle(
                          color: AppColors.warning, 
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history, size: 14, color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            "Original Dates",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd MMM, yyyy').format(request.startDate)} - ${DateFormat('dd MMM, yyyy').format(request.endDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.event_available, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            "New Dates",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd MMM, yyyy').format(request.modificationStartDate!)} - ${DateFormat('dd MMM, yyyy').format(request.modificationEndDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    'Modification Reason:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.modificationReason ?? 'No reason provided',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        NeumorphicButton(
                          onPressed: () => _reviewModification(request, 'reject_all'),
                          text: 'Reject All',
                          isOutlined: true,
                          color: AppColors.error,
                          textColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          fontSize: 11,
                          height: 30,
                          width: 100,
                        ),
                        NeumorphicButton(
                          onPressed: () => _reviewModification(request, 'reject_modification'),
                          text: 'Reject Mod',
                          isOutlined: true,
                          color: AppColors.warning,
                          textColor: AppColors.warning,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          fontSize: 11,
                          height: 30,
                          width: 100,
                        ),
                        NeumorphicButton(
                          onPressed: () => _reviewModification(request, 'approve'),
                          text: 'Approve Mod',
                          color: AppColors.success,
                          textColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          fontSize: 11,
                          height: 30,
                          width: 100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _reviewModification(LeaveRequest request, String action) async {
    String title;
    String message;
    
    switch (action) {
      case 'approve':
        title = 'Approve Modification';
        message = 'Are you sure you want to approve this modification? The leave dates will be updated.';
        break;
      case 'reject_modification':
        title = 'Reject Modification';
        message = 'Are you sure you want to reject this modification? The original leave dates will remain active.';
        break;
      case 'reject_all':
        title = 'Reject Everything';
        message = 'Are you sure you want to reject the ENTIRE leave request? This will cancel the originally approved leave as well.';
        break;
      default:
        return;
    }

    final confirmed = await ConfirmationDialog.show(
      context,
      title,
      message,
      confirmText: action == 'approve' ? 'Approve' : 'Reject',
      icon: action == 'approve' ? Icons.check_circle_outline : Icons.cancel_outlined,
      isDestructive: action != 'approve',
    );

    if (confirmed == true && mounted) {
      await _showModificationNotesDialog(request, action);
    }
  }

  Future<void> _showModificationNotesDialog(LeaveRequest request, String action) async {
    _reviewNotesController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardBackground
            : AppColorsLight.cardBackground,
        title: Text(
          'Review Notes',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        content: CustomTextField(
          controller: _reviewNotesController,
          label: 'Notes (Optional)',
          hint: 'Add notes...',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approve' ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final authState = await ref.read(authProvider.future);
        if (authState is Authenticated && authState.userType == 'owner') {
          // Use service directly as in coach screen
          final service = ref.read(leaveRequestServiceProvider);
          
          await service.reviewModificationRequest(
            requestId: request.id,
            ownerId: authState.userId,
            action: action,
            reviewNotes: _reviewNotesController.text.trim().isEmpty 
                ? null 
                : _reviewNotesController.text.trim(),
          );

          // Refresh
          ref.invalidate(leaveRequestManagerProvider(coachId: null, status: _selectedFilter == 'all' ? null : _selectedFilter));

          if (mounted) {
            SuccessSnackbar.show(context, 'Processed modification request');
          }
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Failed to process: ${e.toString()}');
        }
      }
    }
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
      await _performLeaveRequestAction(request, isApproval: true);
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
      await _performLeaveRequestAction(
        request, 
        isApproval: isApproval,
        reviewNotes: _reviewNotesController.text.trim().isEmpty ? null : _reviewNotesController.text.trim(),
      );
    }
  }

  Future<void> _performLeaveRequestAction(LeaveRequest request, {required bool isApproval, String? reviewNotes}) async {
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
          reviewNotes: reviewNotes,
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

  Widget _buildLeaveRequestsTab(bool isDark, String? statusFilter, bool isSmallScreen) {
    final leaveRequestsAsync = ref.watch(
      leaveRequestManagerProvider(
        coachId: null,
        status: statusFilter,
      ),
    );

    return Column(
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
                  return _buildEmptyLeaveState(isDark);
                }

                // Sort: pending first, then by submission date
                final sortedRequests = List<LeaveRequest>.from(requests)
                  ..sort((a, b) {
                    if (a.isPending && !b.isPending) return -1;
                    if (!a.isPending && b.isPending) return 1;
                    return b.submittedAt.compareTo(a.submittedAt);
                  });

                return ListView.builder(
                  padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
                  itemCount: sortedRequests.length,
                  itemBuilder: (context, index) {
                    final request = sortedRequests[index];
                    return _buildLeaveRequestCard(request, isDark, isSmallScreen);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationRequestsTab(bool isDark, String? statusFilter, bool isSmallScreen) {
    // Only show pending invites if filter allows
    final showPendingInvites = statusFilter == null || statusFilter == 'all' || statusFilter == 'pending';
    
    final studentRegistrationRequestsAsync = ref.watch(
      studentRegistrationRequestManagerProvider(status: statusFilter),
    );
    
    final coachRegistrationRequestsAsync = ref.watch(
      coachRegistrationRequestManagerProvider(status: statusFilter),
    );
    
    final pendingInvitationsAsync = showPendingInvites
        ? ref.watch(pendingInvitationsProvider)
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);

    return Column(
      children: [
        // Filters
        _buildFilters(isDark),

        // Requests List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studentRegistrationRequestManagerProvider(status: statusFilter));
              if (showPendingInvites) {
                ref.invalidate(pendingInvitationsProvider);
              }
            },
            child: studentRegistrationRequestsAsync.when(
              loading: () => const ListSkeleton(itemCount: 5),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load requests: ${error.toString()}',
                onRetry: () {
                   ref.invalidate(studentRegistrationRequestManagerProvider(status: statusFilter));
                   ref.invalidate(coachRegistrationRequestManagerProvider(status: statusFilter));
                   ref.invalidate(pendingInvitationsProvider);
                },
              ),
              data: (studentRequests) {
                return coachRegistrationRequestsAsync.when(
                  loading: () => const ListSkeleton(itemCount: 2),
                  error: (error, stack) => ErrorDisplay(
                    message: 'Failed to load coach requests: ${error.toString()}',
                    onRetry: () {
                      ref.invalidate(coachRegistrationRequestManagerProvider(status: statusFilter));
                    },
                  ),
                  data: (coachRequests) {
                    return pendingInvitationsAsync.when(
                      loading: () => const ListSkeleton(itemCount: 2),
                      error: (_, __) => _buildRequestsList(studentRequests, coachRequests, [], isDark, isSmallScreen),
                      data: (invitations) => _buildRequestsList(studentRequests, coachRequests, invitations, isDark, isSmallScreen),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsList(
    List<StudentRegistrationRequest> studentRequests, 
    List<CoachRegistrationRequest> coachRequests,
    List<Map<String, dynamic>> invitations, 
    bool isDark,
    bool isSmallScreen
  ) {
    if (studentRequests.isEmpty && coachRequests.isEmpty && invitations.isEmpty) {
      return _buildEmptyRegistrationState(isDark);
    }
    
    // Sort student requests
    final sortedStudentRequests = List<StudentRegistrationRequest>.from(studentRequests)
      ..sort((a, b) {
        if (a.isPending && !b.isPending) return -1;
        if (!a.isPending && b.isPending) return 1;
        return b.submittedAt.compareTo(a.submittedAt);
      });

    // Sort coach requests
    final sortedCoachRequests = List<CoachRegistrationRequest>.from(coachRequests)
      ..sort((a, b) {
        if (a.isPending && !b.isPending) return -1;
        if (!a.isPending && b.isPending) return 1;
        return b.submittedAt.compareTo(a.submittedAt);
      });

    return ListView(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
      children: [
        if (invitations.isNotEmpty) ...[
          _buildSectionHeader('PENDING STUDENT INVITES', isDark),
          ...invitations.map((inv) => _buildPendingInvitationCard(inv, isDark, isSmallScreen)),
          const SizedBox(height: AppDimensions.spacingL),
        ],
        
        if (sortedCoachRequests.isNotEmpty) ...[
          _buildSectionHeader('COACH REGISTRATION REQUESTS', isDark),
          ...sortedCoachRequests.map((req) => _buildCoachRegistrationRequestCard(req, isDark, isSmallScreen)),
          const SizedBox(height: AppDimensions.spacingL),
        ],

        if (sortedStudentRequests.isNotEmpty) ...[
          _buildSectionHeader('STUDENT REGISTRATION REQUESTS', isDark),
          ...sortedStudentRequests.map((req) => _buildRegistrationRequestCard(req, isDark, isSmallScreen)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.spacingS,
        bottom: AppDimensions.spacingM,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPendingInvitationCard(Map<String, dynamic> invitation, bool isDark, bool isSmallScreen) {
    final statusColor = AppColors.warning;
    final statusBgColor = statusColor.withValues(alpha: 0.1);
    final coachName = invitation['coach_name'] ?? 'Unknown Coach';
    final studentEmail = invitation['student_email'] ?? 'No Email';
    final studentPhone = invitation['student_phone'] ?? 'No Phone';
    final dateStr = invitation['created_at'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingM),
      margin: EdgeInsets.only(bottom: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentEmail != 'No Email' ? studentEmail : studentPhone,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invited by $coachName',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
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
                  'WAITING',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildDetailRow(Icons.email_outlined, studentEmail, isDark),
          _buildDetailRow(Icons.phone_outlined, studentPhone, isDark),
          if (date != null)
             _buildDetailRow(
               Icons.calendar_today_outlined, 
               'Invited: ${DateFormat('MMM dd, yyyy').format(date)}', 
               isDark
             ),
          
          const SizedBox(height: AppDimensions.spacingM),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColorsLight.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(
                color: isDark ? AppColors.border : AppColorsLight.border,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Student hasn\'t created an account yet.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyLeaveState(bool isDark) {
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
                  : 'No $_selectedFilter leave requests',
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

  Widget _buildEmptyRegistrationState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_disabled_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'No Registration Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              _selectedFilter == 'all'
                  ? 'No registration requests have been submitted yet'
                  : 'No $_selectedFilter registration requests',
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

  Widget _buildRegistrationRequestCard(StudentRegistrationRequest request, bool isDark, bool isSmallScreen) {
    final statusColor = _getStatusColor(request.status, isDark);
    final statusBgColor = statusColor.withValues(alpha: 0.1);

    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingM),
      margin: EdgeInsets.only(bottom: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Student name and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                    if (request.invitedByCoachName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Invited by ${request.invitedByCoachName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

          // Student Details
          _buildDetailRow(Icons.phone, request.phone, isDark),
          if (request.guardianName != null)
            _buildDetailRow(Icons.person_outline, 'Guardian: ${request.guardianName}', isDark),
          if (request.guardianPhone != null)
            _buildDetailRow(Icons.phone_outlined, 'Guardian Phone: ${request.guardianPhone}', isDark),
          if (request.dateOfBirth != null)
            _buildDetailRow(Icons.cake, 'DOB: ${request.dateOfBirth}', isDark),
          if (request.address != null)
            _buildDetailRow(Icons.location_on, request.address!, isDark),
          if (request.tShirtSize != null)
            _buildDetailRow(Icons.checkroom, 'T-Shirt Size: ${request.tShirtSize}', isDark),
          if (request.bloodGroup != null)
            _buildDetailRow(Icons.bloodtype_outlined, 'Blood Group: ${request.bloodGroup}', isDark),

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
                NeumorphicButton(
                  text: 'Reject',
                  icon: Icons.close,
                  onPressed: () => _rejectRegistrationRequest(request),
                  isOutlined: true,
                  color: AppColors.error,
                  textColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                NeumorphicButton(
                  text: 'Approve',
                  icon: Icons.check,
                  onPressed: () => _approveRegistrationRequest(request),
                  color: AppColors.success,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRegistrationRequest(StudentRegistrationRequest request) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Approve Registration',
      'Are you sure you want to approve this student registration?',
      confirmText: 'Approve',
      cancelText: 'Cancel',
      icon: Icons.check_circle_outline,
    );

    if (confirmed == true && mounted) {
      await _performStudentRegistrationAction(request, isApproval: true);
    }
  }

  Future<void> _rejectRegistrationRequest(StudentRegistrationRequest request) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Reject Registration',
      'Are you sure you want to reject this student registration?',
      confirmText: 'Reject',
      cancelText: 'Cancel',
      icon: Icons.cancel_outlined,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await _showRegistrationReviewNotesDialog(request, isApproval: false);
    }
  }

  Future<void> _showRegistrationReviewNotesDialog(StudentRegistrationRequest request, {required bool isApproval}) async {
    _registrationReviewNotesController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardBackground
            : AppColorsLight.cardBackground,
        title: Text(
          isApproval ? 'Approve Registration' : 'Reject Registration',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        content: CustomTextField(
          controller: _registrationReviewNotesController,
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
      await _performStudentRegistrationAction(
        request,
        isApproval: isApproval,
        reviewNotes: _registrationReviewNotesController.text.trim().isEmpty ? null : _registrationReviewNotesController.text.trim(),
      );
    }
  }

  Future<void> _performStudentRegistrationAction(StudentRegistrationRequest request, {required bool isApproval, String? reviewNotes}) async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState is Authenticated && authState.userType == 'owner') {
        final service = ref.read(studentRegistrationRequestServiceProvider);
        
        await service.updateRequestStatus(
          requestId: request.id,
          ownerId: authState.userId,
          status: isApproval ? 'approved' : 'rejected',
          reviewNotes: reviewNotes,
        );

        // Invalidate to refresh the list
        ref.invalidate(
          studentRegistrationRequestManagerProvider(
            status: _selectedFilter == 'all' ? null : _selectedFilter,
          ),
        );

        if (mounted) {
          SuccessSnackbar.show(
            context,
            'Registration request ${isApproval ? 'approved' : 'rejected'} successfully',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(
          context,
          'Failed to ${isApproval ? 'approve' : 'reject'} registration request: ${e.toString()}',
        );
      }
    }
  }

  Widget _buildCoachRegistrationRequestCard(CoachRegistrationRequest request, bool isDark, bool isSmallScreen) {
    final statusColor = _getStatusColor(request.status, isDark);
    final statusBgColor = statusColor.withValues(alpha: 0.1);

    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingM),
      margin: EdgeInsets.only(bottom: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
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
                      request.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.email,
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

          // Coach Details
          _buildDetailRow(Icons.phone, request.phone, isDark),
          if (request.specialization != null)
            _buildDetailRow(Icons.star_outline, 'Specialization: ${request.specialization}', isDark),
          if (request.experienceYears != null)
            _buildDetailRow(Icons.history, 'Experience: ${request.experienceYears} years', isDark),

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
                NeumorphicButton(
                  text: 'Reject',
                  icon: Icons.close,
                  onPressed: () => _rejectCoachRegistrationRequest(request),
                  isOutlined: true,
                  color: AppColors.error,
                  textColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                NeumorphicButton(
                  text: 'Approve',
                  icon: Icons.check,
                  onPressed: () => _approveCoachRegistrationRequest(request),
                  color: AppColors.success,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _approveCoachRegistrationRequest(CoachRegistrationRequest request) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Approve Coach',
      'Are you sure you want to approve this coach registration?',
      confirmText: 'Approve',
      cancelText: 'Cancel',
      icon: Icons.check_circle_outline,
    );

    if (confirmed == true && mounted) {
      await _performCoachRegistrationAction(request, isApproval: true);
    }
  }

  Future<void> _rejectCoachRegistrationRequest(CoachRegistrationRequest request) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Reject Coach',
      'Are you sure you want to reject this coach registration?',
      confirmText: 'Reject',
      cancelText: 'Cancel',
      icon: Icons.cancel_outlined,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await _showCoachRegistrationReviewNotesDialog(request, isApproval: false);
    }
  }

  Future<void> _showCoachRegistrationReviewNotesDialog(CoachRegistrationRequest request, {required bool isApproval}) async {
    _registrationReviewNotesController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardBackground
            : AppColorsLight.cardBackground,
        title: Text(
          isApproval ? 'Approve Coach' : 'Reject Coach',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        content: CustomTextField(
          controller: _registrationReviewNotesController,
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
      await _performCoachRegistrationAction(
        request,
        isApproval: isApproval,
        reviewNotes: _registrationReviewNotesController.text.trim().isEmpty ? null : _registrationReviewNotesController.text.trim(),
      );
    }
  }

  Future<void> _performCoachRegistrationAction(CoachRegistrationRequest request, {required bool isApproval, String? reviewNotes}) async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState is Authenticated && authState.userType == 'owner') {
        final service = ref.read(coachRegistrationRequestServiceProvider);
        
        await service.updateRequestStatus(
          requestId: request.id,
          ownerId: authState.userId,
          status: isApproval ? 'approved' : 'rejected',
          reviewNotes: reviewNotes,
        );

        // Invalidate to refresh the list
        ref.invalidate(
          coachRegistrationRequestManagerProvider(
            status: _selectedFilter == 'all' ? null : _selectedFilter,
          ),
        );

        if (mounted) {
          SuccessSnackbar.show(
            context,
            'Coach registration request ${isApproval ? 'approved' : 'rejected'} successfully',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(
          context,
          'Failed to ${isApproval ? 'approve' : 'reject'} coach registration request: ${e.toString()}',
        );
      }
    }
  }

  Widget _buildRejoinRequestsTab(bool isDark, bool isSmallScreen) {
    final studentsAsync = ref.watch(studentListProvider);

    return studentsAsync.when(
      data: (students) {
        final rejoinRequests = students.where((s) => s.rejoinRequestPending).toList();

        if (rejoinRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_pin_outlined,
                  size: 64,
                  color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'No Rejoin Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  'Students who were marked inactive will appear here if they request to rejoin.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
          itemCount: rejoinRequests.length,
          itemBuilder: (context, index) {
            final student = rejoinRequests[index];
            return _buildRejoinRequestCard(student, isDark, isSmallScreen);
          },
        );
      },
      loading: () => const ListSkeleton(itemCount: 3),
      error: (error, _) => ErrorDisplay(
        message: 'Failed to load rejoin requests',
        onRetry: () => ref.refresh(studentListProvider),
      ),
    );
  }

  Widget _buildRejoinRequestCard(Student student, bool isDark, bool isSmallScreen) {
    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingM),
      margin: EdgeInsets.only(bottom: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.accent),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      student.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'This student has requested to rejoin the academy. Approving will mark their account as "Active" again.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NeumorphicButton(
                text: 'Approve Rejoin',
                icon: Icons.check,
                onPressed: () => _approveRejoin(student),
                color: AppColors.success,
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approveRejoin(Student student) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Approve Rejoin',
      'Are you sure you want to approve ${student.name}\'s request to rejoin?',
      confirmText: 'Approve',
      icon: Icons.check_circle_outline,
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(studentListProvider.notifier).approveRejoin(student.id);
        if (mounted) {
          SuccessSnackbar.show(context, 'Rejoin request approved for ${student.name}');
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Failed to approve: ${e.toString()}');
        }
      }
    }
  }
}
