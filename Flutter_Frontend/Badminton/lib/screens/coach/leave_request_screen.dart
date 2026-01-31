import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';

/// Leave Request Screen - Submit and view leave requests
class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  bool _showAddForm = false;
  final _reasonController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  String _selectedLeaveType = 'sick'; // 'sick', 'personal', 'emergency', 'other'
  bool _isLoading = false;

  // Mock data - In a real app, this would come from a provider/service
  final List<Map<String, dynamic>> _leaveRequests = [];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitLeaveRequest() async {
    if (_reasonController.text.trim().isEmpty) {
      SuccessSnackbar.showError(context, 'Please enter a reason for leave');
      return;
    }

    if (_selectedStartDate.isAfter(_selectedEndDate)) {
      SuccessSnackbar.showError(context, 'End date must be after start date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call to submit leave request
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

      final newRequest = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'startDate': _selectedStartDate,
        'endDate': _selectedEndDate,
        'type': _selectedLeaveType,
        'reason': _reasonController.text.trim(),
        'status': 'pending',
        'submittedDate': DateTime.now(),
      };

      setState(() {
        _leaveRequests.insert(0, newRequest);
        _showAddForm = false;
        _reasonController.clear();
        _selectedStartDate = DateTime.now();
        _selectedEndDate = DateTime.now();
        _selectedLeaveType = 'sick';
        _isLoading = false;
      });

      if (mounted) {
        SuccessSnackbar.show(context, 'Leave request submitted successfully');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to submit leave request: ${e.toString()}');
      }
    }
  }

  Future<void> _cancelLeaveRequest(int requestId) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Cancel Leave Request',
      'Are you sure you want to cancel this leave request?',
      confirmText: 'Cancel Request',
    );

    if (confirmed == true && mounted) {
      try {
        // TODO: Implement actual API call to cancel leave request
        await Future.delayed(const Duration(milliseconds: 300));

        setState(() {
          _leaveRequests.removeWhere((req) => req['id'] == requestId);
        });

        if (mounted) {
          SuccessSnackbar.show(context, 'Leave request cancelled');
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Failed to cancel leave request: ${e.toString()}');
        }
      }
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success.toString();
      case 'rejected':
        return AppColors.error.toString();
      case 'pending':
        return AppColors.warning.toString();
      default:
        return AppColors.textSecondary.toString();
    }
  }

  Color _getStatusColorObj(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getLeaveTypeLabel(String type) {
    switch (type) {
      case 'sick':
        return 'Sick Leave';
      case 'personal':
        return 'Personal Leave';
      case 'emergency':
        return 'Emergency';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_showAddForm) {
      return _buildAddForm(isDark);
    }

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
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? AppColors.accent : AppColorsLight.accent,
            ),
            onPressed: () => setState(() => _showAddForm = true),
          ),
        ],
      ),
      body: _leaveRequests.isEmpty
          ? _buildEmptyState(isDark)
          : RefreshIndicator(
              onRefresh: () async {
                // TODO: Refresh leave requests from API
                await Future.delayed(const Duration(milliseconds: 300));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                itemCount: _leaveRequests.length,
                itemBuilder: (context, index) {
                  final request = _leaveRequests[index];
                  return _buildLeaveRequestCard(request, isDark);
                },
              ),
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
              'Submit a leave request to get started',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showAddForm = true),
              icon: const Icon(Icons.add),
              label: const Text('Submit Leave Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.spacingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestCard(Map<String, dynamic> request, bool isDark) {
    final startDate = request['startDate'] as DateTime;
    final endDate = request['endDate'] as DateTime;
    final status = request['status'] as String;
    final type = request['type'] as String;
    final reason = request['reason'] as String;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
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
                      _getLeaveTypeLabel(type),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd MMM, yyyy').format(startDate)} - ${DateFormat('dd MMM, yyyy').format(endDate)}',
                      style: TextStyle(
                        fontSize: 12,
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
                  color: _getStatusColorObj(status).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColorObj(status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            reason,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          if (status == 'pending') ...[
            const SizedBox(height: AppDimensions.spacingM),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _cancelLeaveRequest(request['id'] as int),
                child: Text(
                  'Cancel Request',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddForm(bool isDark) {
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
          onPressed: () => setState(() => _showAddForm = false),
        ),
        title: Text(
          'Submit Leave Request',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave Type
              const Text(
                'Leave Type',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Row(
                children: [
                  Expanded(
                    child: _LeaveTypeButton(
                      label: 'Sick',
                      value: 'sick',
                      selected: _selectedLeaveType,
                      onTap: () => setState(() => _selectedLeaveType = 'sick'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: _LeaveTypeButton(
                      label: 'Personal',
                      value: 'personal',
                      selected: _selectedLeaveType,
                      onTap: () => setState(() => _selectedLeaveType = 'personal'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Row(
                children: [
                  Expanded(
                    child: _LeaveTypeButton(
                      label: 'Emergency',
                      value: 'emergency',
                      selected: _selectedLeaveType,
                      onTap: () => setState(() => _selectedLeaveType = 'emergency'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: _LeaveTypeButton(
                      label: 'Other',
                      value: 'other',
                      selected: _selectedLeaveType,
                      onTap: () => setState(() => _selectedLeaveType = 'other'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Start Date
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedStartDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _selectedStartDate = date);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        'Start Date: ${DateFormat('dd MMM, yyyy').format(_selectedStartDate)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // End Date
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedEndDate,
                      firstDate: _selectedStartDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _selectedEndDate = date);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        'End Date: ${DateFormat('dd MMM, yyyy').format(_selectedEndDate)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Reason
              CustomTextField(
                controller: _reasonController,
                label: 'Reason',
                hint: 'Enter reason for leave',
                maxLines: 4,
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLeaveRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveTypeButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _LeaveTypeButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
