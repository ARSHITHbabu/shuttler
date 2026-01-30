import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/request_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../models/request.dart';

/// Coach Leave Request Screen - Submit and view leave requests
class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get coach's leave requests
    final authState = ref.watch(authProvider);
    int? coachId;

    authState.whenData((authValue) {
      if (authValue is Authenticated && authValue.userType == 'coach') {
        coachId = authValue.userId;
      }
    });

    final leaveRequestsAsync = coachId != null
        ? ref.watch(requestsByTypeProvider('coach_leave', status: null))
        : const AsyncValue<List<Request>>.data([]);

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Submit Leave Request Form
            Text(
              'Request Leave',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start Date
                    Text(
                      'Start Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, isStartDate: true),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.spacingM),
                            Expanded(
                              child: Text(
                                _startDate != null
                                    ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                    : 'Select start date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _startDate != null
                                      ? (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary)
                                      : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    // End Date
                    Text(
                      'End Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, isStartDate: false),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.spacingM),
                            Expanded(
                              child: Text(
                                _endDate != null
                                    ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                    : 'Select end date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _endDate != null
                                      ? (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary)
                                      : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    // Reason
                    Text(
                      'Reason',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter reason for leave...',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.border : AppColorsLight.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.border : AppColorsLight.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.accent : AppColorsLight.accent,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitLeaveRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.accent : AppColorsLight.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit Leave Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Leave Request History
            Text(
              'My Leave Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            leaveRequestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Failed to load requests: ${error.toString()}',
                style: TextStyle(
                  color: isDark ? AppColors.error : AppColorsLight.error,
                ),
              ),
              data: (requests) {
                if (requests.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingXl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 48,
                            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          Text(
                            'No leave requests yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Filter to show only this coach's requests
                final coachRequests = requests.where((r) => r.requesterId == coachId).toList();

                if (coachRequests.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingXl),
                      child: Text(
                        'No leave requests yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: coachRequests.length,
                  itemBuilder: (context, index) {
                    return _LeaveRequestCard(
                      request: coachRequests[index],
                      isDark: isDark,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, reset it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      SuccessSnackbar.showError(context, 'Please select both start and end dates');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      SuccessSnackbar.showError(context, 'End date must be after start date');
      return;
    }

    final authState = ref.read(authProvider);
    int? coachId;
    String? coachName;

    authState.whenData((authValue) {
      if (authValue is Authenticated && authValue.userType == 'coach') {
        coachId = authValue.userId;
        coachName = authValue.userName;
      }
    });

    if (coachId == null) {
      SuccessSnackbar.showError(context, 'Unable to identify coach');
      return;
    }

    try {
      final requestService = ref.read(requestServiceProvider);
      await requestService.createRequest(
        requestType: 'coach_leave',
        requesterType: 'coach',
        requesterId: coachId!,
        title: 'Leave Request: ${DateFormat('MMM dd - MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
        description: _reasonController.text.trim(),
        metadata: {
          'start_date': _startDate!.toIso8601String(),
          'end_date': _endDate!.toIso8601String(),
          'coach_name': coachName,
        },
      );

      if (mounted) {
        SuccessSnackbar.show(context, 'Leave request submitted successfully');
        _formKey.currentState!.reset();
        _reasonController.clear();
        setState(() {
          _startDate = null;
          _endDate = null;
        });
        ref.invalidate(requestsByTypeProvider);
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to submit leave request: ${e.toString()}');
      }
    }
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final Request request;
  final bool isDark;

  const _LeaveRequestCard({
    required this.request,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    String? startDate;
    String? endDate;

    if (request.metadata != null) {
      try {
        if (request.metadata!['start_date'] != null) {
          startDate = DateFormat('MMM dd, yyyy')
              .format(DateTime.parse(request.metadata!['start_date']));
        }
        if (request.metadata!['end_date'] != null) {
          endDate = DateFormat('MMM dd, yyyy')
              .format(DateTime.parse(request.metadata!['end_date']));
        }
      } catch (e) {
        // Handle parsing error
      }
    }

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (startDate != null && endDate != null)
                      Text(
                        '$startDate - $endDate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(request.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: request.status, isDark: isDark),
            ],
          ),
          if (request.description != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              request.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ],
          if (request.responseMessage != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.accent : AppColorsLight.accent)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    request.isApproved ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: request.isApproved
                        ? (isDark ? AppColors.success : AppColorsLight.success)
                        : (isDark ? AppColors.error : AppColorsLight.error),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.responseMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
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
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusBadge({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
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
