import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  String _selectedStatusFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'
  bool _showAddForm = false;
  final Set<DateTime> _selectedDates = {};
  bool _isHalfDay = false;
  DateTime _focusedDay = DateTime.now();

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
        ? ref.watch(
            requestListProvider(
              requestType: 'coach_leave',
              requesterId: coachId,
              status: _selectedStatusFilter == 'all' ? null : _selectedStatusFilter,
            ),
          )
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
        actions: [
          // Plus button to add request
          IconButton(
            icon: Icon(
              _showAddForm ? Icons.close : Icons.add,
              color: isDark ? AppColors.accent : AppColorsLight.accent,
            ),
            onPressed: () {
              setState(() {
                _showAddForm = !_showAddForm;
                if (!_showAddForm) {
                  _selectedDates.clear();
                  _reasonController.clear();
                  _isHalfDay = false;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter
            _buildStatusFilter(isDark),

            const SizedBox(height: AppDimensions.spacingL),

            // Add Leave Request Form
            if (_showAddForm) ...[
              _buildAddForm(isDark),
              const SizedBox(height: AppDimensions.spacingL),
            ],

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

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return _LeaveRequestCard(
                      request: requests[index],
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

  Widget _buildStatusFilter(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedStatusFilter == 'all',
            onTap: () => setState(() => _selectedStatusFilter = 'all'),
            isDark: isDark,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          _FilterChip(
            label: 'Pending',
            isSelected: _selectedStatusFilter == 'pending',
            onTap: () => setState(() => _selectedStatusFilter = 'pending'),
            color: Colors.orange,
            isDark: isDark,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          _FilterChip(
            label: 'Approved',
            isSelected: _selectedStatusFilter == 'approved',
            onTap: () => setState(() => _selectedStatusFilter = 'approved'),
            color: Colors.green,
            isDark: isDark,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          _FilterChip(
            label: 'Rejected',
            isSelected: _selectedStatusFilter == 'rejected',
            onTap: () => setState(() => _selectedStatusFilter = 'rejected'),
            color: Colors.red,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm(bool isDark) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave Type (Fixed as Leave)
            Text(
              'Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 20,
                    color: isDark ? AppColors.accent : AppColorsLight.accent,
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Text(
                    'Leave',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Date Selection with Calendar
            Text(
              'Select Dates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showCalendarPicker(isDark),
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
                        _selectedDates.isEmpty
                            ? 'Tap to select dates'
                            : _formatSelectedDates(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedDates.isEmpty
                              ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)
                              : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                        ),
                      ),
                    ),
                    if (_selectedDates.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDates.clear();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_selectedDates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${_selectedDates.length} day${_selectedDates.length > 1 ? 's' : ''} selected',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.spacingM),

            // Half Day Option
            Row(
              children: [
                Checkbox(
                  value: _isHalfDay,
                  onChanged: (value) {
                    setState(() {
                      _isHalfDay = value ?? false;
                    });
                  },
                  activeColor: isDark ? AppColors.accent : AppColorsLight.accent,
                ),
                Text(
                  'Half Day',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
              ],
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
                  'Send Request',
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
    );
  }

  String _formatSelectedDates() {
    if (_selectedDates.isEmpty) return '';
    
    final sortedDates = _selectedDates.toList()..sort();
    if (sortedDates.length == 1) {
      return DateFormat('MMM dd, yyyy').format(sortedDates[0]);
    }
    
    // Check if dates are consecutive
    bool isConsecutive = true;
    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff != 1) {
        isConsecutive = false;
        break;
      }
    }
    
    if (isConsecutive) {
      return '${DateFormat('MMM dd').format(sortedDates.first)} - ${DateFormat('MMM dd, yyyy').format(sortedDates.last)}';
    } else {
      return '${sortedDates.length} days selected';
    }
  }

  Future<void> _showCalendarPicker(bool isDark) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          constraints: const BoxConstraints(maxWidth: 400),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Leave Dates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  TableCalendar<dynamic>(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      final dateKey = DateTime(day.year, day.month, day.day);
                      return _selectedDates.contains(dateKey);
                    },
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                      defaultTextStyle: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                      selectedDecoration: BoxDecoration(
                        color: isDark ? AppColors.accent : AppColorsLight.accent,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: (isDark ? AppColors.accent : AppColorsLight.accent).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setDialogState(() {
                        final dateKey = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                        if (_selectedDates.contains(dateKey)) {
                          _selectedDates.remove(dateKey);
                        } else {
                          // Check if adding this date would exceed 1 week
                          if (_selectedDates.length >= 7) {
                            SuccessSnackbar.showError(context, 'Maximum 7 days allowed');
                            return;
                          }
                          _selectedDates.add(dateKey);
                        }
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setDialogState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  if (_selectedDates.isNotEmpty) ...[
                    Text(
                      'Selected: ${_formatSelectedDates()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            _selectedDates.clear();
                          });
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.accent : AppColorsLight.accent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    setState(() {}); // Refresh UI after dialog closes
  }

  Future<void> _submitLeaveRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDates.isEmpty) {
      SuccessSnackbar.showError(context, 'Please select at least one date');
      return;
    }

    // Validate max 7 days
    if (_selectedDates.length > 7) {
      SuccessSnackbar.showError(context, 'Maximum 7 days allowed for leave request');
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
      final sortedDates = _selectedDates.toList()..sort();
      final startDate = sortedDates.first;
      final endDate = sortedDates.last;
      
      final dateStrings = sortedDates.map((d) => d.toIso8601String().split('T')[0]).toList();
      
      final requestService = ref.read(requestServiceProvider);
      await requestService.createRequest(
        requestType: 'coach_leave',
        requesterType: 'coach',
        requesterId: coachId!,
        title: 'Leave Request: ${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}${_isHalfDay ? ' (Half Day)' : ''}',
        description: _reasonController.text.trim(),
        metadata: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'dates': dateStrings,
          'is_half_day': _isHalfDay,
          'coach_name': coachName,
          'total_days': sortedDates.length,
        },
      );

      if (mounted) {
        SuccessSnackbar.show(context, 'Leave request submitted successfully');
        _formKey.currentState!.reset();
        _reasonController.clear();
        setState(() {
          _selectedDates.clear();
          _isHalfDay = false;
          _showAddForm = false;
        });
        ref.invalidate(requestListProvider);
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
    bool isHalfDay = false;
    int? totalDays;

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
        isHalfDay = request.metadata!['is_half_day'] == true;
        totalDays = request.metadata!['total_days'] as int?;
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
                        startDate == endDate
                            ? '$startDate${isHalfDay ? ' (Half Day)' : ''}'
                            : '$startDate - $endDate${isHalfDay ? ' (Half Day)' : ''}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        ),
                      ),
                    if (totalDays != null && totalDays > 1)
                      Text(
                        '$totalDays days',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? (isDark ? AppColors.accent : AppColorsLight.accent);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.textTertiary : AppColorsLight.textTertiary),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
          ),
        ),
      ),
    );
  }
}
