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
import '../../providers/request_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/student_provider.dart';
import '../../providers/coach_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/more_screen_app_bar.dart';
import '../../models/request.dart';

/// Requests Screen - Owner's centralized request management
class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  String _selectedStatusFilter =
      'all'; // 'all', 'pending', 'approved', 'rejected'
  String _selectedTypeFilter =
      'all'; // 'all', 'student_registration', 'coach_leave', etc.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get requests based on filters
    final requestsAsync = ref.watch(
      requestListProvider(
        requestType: _selectedTypeFilter == 'all' ? null : _selectedTypeFilter,
        status: _selectedStatusFilter == 'all' ? null : _selectedStatusFilter,
      ),
    );

    // Get pending count for badge
    final pendingCountAsync = ref.watch(pendingRequestsCountProvider);

    void _handleReload() {
      ref.invalidate(requestListProvider);
      ref.invalidate(pendingRequestsCountProvider);
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColorsLight.background,
      appBar: MoreScreenAppBar(
        title: 'Requests',
        onReload: _handleReload,
        isDark: isDark,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _handleReload();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: Column(
        children: [
          // Stats Cards
          pendingCountAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (pendingCount) => _buildStatsCards(isDark, pendingCount),
          ),

          // Filters
          _buildFilters(isDark),

          // Requests List
          Expanded(
            child: requestsAsync.when(
              loading: () => const ListSkeleton(itemCount: 5),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load requests: ${error.toString()}',
                onRetry: () => ref.invalidate(requestListProvider),
              ),
              data: (requests) {
                if (requests.isEmpty) {
                  return _buildEmptyState(isDark);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return _RequestCard(
                      request: requests[index],
                      isDark: isDark,
                      onApprove: () => requests[index].requestType == 'coach_leave_modification'
                          ? _handleModificationRequest(requests[index])
                          : _handleApprove(requests[index]),
                      onReject: () => _handleReject(requests[index]),
                      onView: () =>
                          _showRequestDetails(requests[index], isDark),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDark, int pendingCount) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          Expanded(
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColorsLight.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$pendingCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.accent
                              : AppColorsLight.accent,
                        ),
                      ),
                      if (pendingCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8, bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.accent
                                        : AppColorsLight.accent)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'New',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.accent
                                  : AppColorsLight.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Filter
          Text(
            'Status',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
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
                  onTap: () =>
                      setState(() => _selectedStatusFilter = 'pending'),
                  color: Colors.orange,
                  isDark: isDark,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                _FilterChip(
                  label: 'Approved',
                  isSelected: _selectedStatusFilter == 'approved',
                  onTap: () =>
                      setState(() => _selectedStatusFilter = 'approved'),
                  color: Colors.green,
                  isDark: isDark,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                _FilterChip(
                  label: 'Rejected',
                  isSelected: _selectedStatusFilter == 'rejected',
                  onTap: () =>
                      setState(() => _selectedStatusFilter = 'rejected'),
                  color: Colors.red,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Type Filter
          Text(
            'Type',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedTypeFilter == 'all',
                  onTap: () => setState(() => _selectedTypeFilter = 'all'),
                  isDark: isDark,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                _FilterChip(
                  label: 'Student Reg',
                  isSelected: _selectedTypeFilter == 'student_registration',
                  onTap: () => setState(
                    () => _selectedTypeFilter = 'student_registration',
                  ),
                  isDark: isDark,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                _FilterChip(
                  label: 'Coach Reg',
                  isSelected: _selectedTypeFilter == 'coach_registration',
                  onTap: () => setState(
                    () => _selectedTypeFilter = 'coach_registration',
                  ),
                  isDark: isDark,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                _FilterChip(
                  label: 'Leave',
                  isSelected: _selectedTypeFilter == 'coach_leave',
                  onTap: () =>
                      setState(() => _selectedTypeFilter = 'coach_leave'),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: isDark
                ? AppColors.textTertiary
                : AppColorsLight.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'No requests found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All requests have been processed',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textTertiary
                  : AppColorsLight.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(Request request) async {
    final confirm = await ConfirmationDialog.show(
      context,
      'Approve Request',
      'Are you sure you want to approve this request?',
      confirmText: 'Approve',
      cancelText: 'Cancel',
      icon: Icons.check_circle_outline,
    );

    if (confirm == true && mounted) {
      try {
        final requestService = ref.read(requestServiceProvider);
        await requestService.approveRequest(request.id);

        // Handle coach leave requests and modifications
        if ((request.requestType == 'coach_leave' || request.requestType == 'coach_leave_modification') && request.metadata != null) {
          try {
            final authState = ref.read(authProvider);
            int? ownerId;
            String? coachName;

            authState.whenData((authValue) {
              if (authValue is Authenticated && authValue.userType == 'owner') {
                ownerId = authValue.userId;
              }
            });

            final calendarService = ref.read(calendarServiceProvider);

            if (request.requestType == 'coach_leave_modification') {
              // Handle modification: delete old events and create new ones
              coachName = request.metadata!['coach_name'] as String? ?? 'Coach';
              final originalIsHalfDay = request.metadata!['original_is_half_day'] == true;
              final newIsHalfDay = request.metadata!['new_is_half_day'] == true;

              // Get original dates
              List<DateTime> originalDates = [];
              if (request.metadata!['original_dates'] != null) {
                final datesList = request.metadata!['original_dates'] as List<dynamic>?;
                if (datesList != null) {
                  originalDates = datesList.map((d) => DateTime.parse(d as String)).toList();
                }
              }

              // Get new dates
              List<DateTime> newDates = [];
              if (request.metadata!['new_dates'] != null) {
                final datesList = request.metadata!['new_dates'] as List<dynamic>?;
                if (datesList != null) {
                  newDates = datesList.map((d) => DateTime.parse(d as String)).toList();
                }
              }

              if (ownerId != null && originalDates.isNotEmpty && newDates.isNotEmpty) {
                // Get all calendar events for the date range to find matching leave events
                final minDate = originalDates.first.isBefore(newDates.first) 
                    ? originalDates.first 
                    : newDates.first;
                final maxDate = originalDates.last.isAfter(newDates.last) 
                    ? originalDates.last 
                    : newDates.last;
                
                final allEvents = await calendarService.getCalendarEvents(
                  startDate: minDate.subtract(const Duration(days: 1)),
                  endDate: maxDate.add(const Duration(days: 1)),
                  eventType: 'leave',
                );

                // Find and delete events matching the original leave dates and coach name
                final originalDateStrings = originalDates.map((d) => d.toIso8601String().split('T')[0]).toSet();
                final originalEventTitle = originalIsHalfDay 
                    ? '$coachName - Leave (Half Day)'
                    : '$coachName - Leave';

                for (final event in allEvents) {
                  final eventDateStr = event.date.toIso8601String().split('T')[0];
                  if (originalDateStrings.contains(eventDateStr) && 
                      event.title == originalEventTitle) {
                    try {
                      await calendarService.deleteCalendarEvent(event.id);
                    } catch (e) {
                      debugPrint('Failed to delete calendar event ${event.id}: $e');
                    }
                  }
                }

                // Create new calendar events for the new dates
                for (final date in newDates) {
                  final eventTitle = newIsHalfDay 
                      ? '$coachName - Leave (Half Day)'
                      : '$coachName - Leave';
                  
                  final eventData = {
                    'title': eventTitle,
                    'event_type': 'leave',
                    'date': date.toIso8601String().split('T')[0],
                    'created_by': ownerId,
                    'creator_type': 'owner',
                    'description': request.description ?? 'Coach leave modification',
                  };

                  await calendarService.createCalendarEvent(eventData);
                }

                // Note: The modification request itself contains all the info needed
                // The original request metadata doesn't need to be updated as the modification
                // request serves as the record of the change
              }
            } else {
              // Handle regular leave request: create calendar events
              coachName = request.metadata!['coach_name'] as String? ?? 'Coach';
              final isHalfDay = request.metadata!['is_half_day'] == true;

              // Get dates from metadata
              List<DateTime> leaveDates = [];
              if (request.metadata!['dates'] != null) {
                // If dates array exists, use it
                final datesList = request.metadata!['dates'] as List<dynamic>?;
                if (datesList != null) {
                  leaveDates = datesList.map((d) => DateTime.parse(d as String)).toList();
                }
              } else if (request.metadata!['start_date'] != null && request.metadata!['end_date'] != null) {
                // Otherwise, generate dates from start to end
                final startDate = DateTime.parse(request.metadata!['start_date']);
                final endDate = DateTime.parse(request.metadata!['end_date']);
                var currentDate = startDate;
                while (!currentDate.isAfter(endDate)) {
                  leaveDates.add(currentDate);
                  currentDate = currentDate.add(const Duration(days: 1));
                }
              }

              if (ownerId != null && leaveDates.isNotEmpty) {
                // Create calendar events for each leave date
                for (final date in leaveDates) {
                  final eventTitle = isHalfDay 
                      ? '$coachName - Leave (Half Day)'
                      : '$coachName - Leave';
                  
                  final eventData = {
                    'title': eventTitle,
                    'event_type': 'leave',
                    'date': date.toIso8601String().split('T')[0],
                    'created_by': ownerId,
                    'creator_type': 'owner',
                    'description': request.description ?? 'Coach leave request',
                  };

                  await calendarService.createCalendarEvent(eventData);
                }
              }
            }
            
            // Invalidate calendar providers to refresh the calendar
            ref.invalidate(calendarEventsProvider);
            ref.invalidate(calendarEventListProvider);
          } catch (e) {
            // Log error but don't fail the approval
            debugPrint('Failed to process calendar events: $e');
          }
        }

        if (mounted) {
          SuccessSnackbar.show(context, 'Request approved successfully');
          ref.invalidate(requestListProvider);
          ref.invalidate(pendingRequestsCountProvider);

          // Invalidate student/coach lists if registration request was approved
          if (request.requestType == 'student_registration') {
            ref.invalidate(studentListProvider);
          } else if (request.requestType == 'coach_registration') {
            ref.invalidate(coachListProvider);
          }
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(
            context,
            'Failed to approve request: ${e.toString()}',
          );
        }
      }
    }
  }

  Future<void> _handleModificationRequest(Request modificationRequest) async {
    if (modificationRequest.metadata == null) {
      SuccessSnackbar.showError(context, 'Invalid modification request');
      return;
    }

    final originalRequestId = modificationRequest.metadata!['original_request_id'] as int?;
    if (originalRequestId == null) {
      SuccessSnackbar.showError(context, 'Original request not found');
      return;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show dialog with three options
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.cardBackground
            : AppColorsLight.cardBackground,
        title: Text(
          'Modification Request',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        content: Text(
          'Choose an action for this modification request:',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('approve_modification'),
            child: Text(
              'Approve Modification',
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('reject_modification'),
            child: Text(
              'Reject Modification',
              style: TextStyle(
                color: Colors.orange,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('reject_whole_leave'),
            child: Text(
              'Reject Whole Leave',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == null || result == 'cancel' || !mounted) return;

    try {
      final requestService = ref.read(requestServiceProvider);
      final calendarService = ref.read(calendarServiceProvider);
      final authState = ref.read(authProvider);
      int? ownerId;

      authState.whenData((authValue) {
        if (authValue is Authenticated && authValue.userType == 'owner') {
          ownerId = authValue.userId;
        }
      });

      if (result == 'approve_modification') {
        // Approve modification: update calendar events
        await requestService.approveRequest(modificationRequest.id);
        
        // Update calendar events (delete old, create new)
        final coachName = modificationRequest.metadata!['coach_name'] as String? ?? 'Coach';
        final originalIsHalfDay = modificationRequest.metadata!['original_is_half_day'] == true;
        final newIsHalfDay = modificationRequest.metadata!['new_is_half_day'] == true;

        List<DateTime> originalDates = [];
        if (modificationRequest.metadata!['original_dates'] != null) {
          final datesList = modificationRequest.metadata!['original_dates'] as List<dynamic>?;
          if (datesList != null) {
            originalDates = datesList.map((d) => DateTime.parse(d as String)).toList();
          }
        }

        List<DateTime> newDates = [];
        if (modificationRequest.metadata!['new_dates'] != null) {
          final datesList = modificationRequest.metadata!['new_dates'] as List<dynamic>?;
          if (datesList != null) {
            newDates = datesList.map((d) => DateTime.parse(d as String)).toList();
          }
        }

        if (ownerId != null && originalDates.isNotEmpty && newDates.isNotEmpty) {
          // Get all calendar events for the date range
          final minDate = originalDates.first.isBefore(newDates.first) 
              ? originalDates.first 
              : newDates.first;
          final maxDate = originalDates.last.isAfter(newDates.last) 
              ? originalDates.last 
              : newDates.last;
          
          final allEvents = await calendarService.getCalendarEvents(
            startDate: minDate.subtract(const Duration(days: 1)),
            endDate: maxDate.add(const Duration(days: 1)),
            eventType: 'leave',
          );

          // Delete old events
          final originalDateStrings = originalDates.map((d) => d.toIso8601String().split('T')[0]).toSet();
          final originalEventTitle = originalIsHalfDay 
              ? '$coachName - Leave (Half Day)'
              : '$coachName - Leave';

          for (final event in allEvents) {
            final eventDateStr = event.date.toIso8601String().split('T')[0];
            if (originalDateStrings.contains(eventDateStr) && 
                event.title == originalEventTitle) {
              try {
                await calendarService.deleteCalendarEvent(event.id);
              } catch (e) {
                debugPrint('Failed to delete calendar event ${event.id}: $e');
              }
            }
          }

          // Create new events
          for (final date in newDates) {
            final eventTitle = newIsHalfDay 
                ? '$coachName - Leave (Half Day)'
                : '$coachName - Leave';
            
            final eventData = {
              'title': eventTitle,
              'event_type': 'leave',
              'date': date.toIso8601String().split('T')[0],
              'created_by': ownerId,
              'creator_type': 'owner',
              'description': modificationRequest.description ?? 'Coach leave modification',
            };

            await calendarService.createCalendarEvent(eventData);
          }
        }

        if (mounted) {
          SuccessSnackbar.show(context, 'Modification approved successfully');
        }
      } else if (result == 'reject_modification') {
        // Reject modification: keep original leave, just reject the modification request
        await requestService.rejectRequest(modificationRequest.id, responseMessage: 'Modification rejected. Original leave remains approved.');
        
        if (mounted) {
          SuccessSnackbar.show(context, 'Modification rejected. Original leave remains.');
        }
      } else if (result == 'reject_whole_leave') {
        // Reject whole leave: reject both modification and original request, delete calendar events
        await requestService.rejectRequest(modificationRequest.id, responseMessage: 'Whole leave request rejected.');
        
        // Also reject the original request
        try {
          await requestService.rejectRequest(originalRequestId, responseMessage: 'Leave request rejected due to modification rejection.');
        } catch (e) {
          debugPrint('Failed to reject original request: $e');
        }

        // Delete calendar events for original leave
        final coachName = modificationRequest.metadata!['coach_name'] as String? ?? 'Coach';
        final originalIsHalfDay = modificationRequest.metadata!['original_is_half_day'] == true;

        List<DateTime> originalDates = [];
        if (modificationRequest.metadata!['original_dates'] != null) {
          final datesList = modificationRequest.metadata!['original_dates'] as List<dynamic>?;
          if (datesList != null) {
            originalDates = datesList.map((d) => DateTime.parse(d as String)).toList();
          }
        }

        if (ownerId != null && originalDates.isNotEmpty) {
          final minDate = originalDates.first.subtract(const Duration(days: 1));
          final maxDate = originalDates.last.add(const Duration(days: 1));
          
          final allEvents = await calendarService.getCalendarEvents(
            startDate: minDate,
            endDate: maxDate,
            eventType: 'leave',
          );

          final originalDateStrings = originalDates.map((d) => d.toIso8601String().split('T')[0]).toSet();
          final originalEventTitle = originalIsHalfDay 
              ? '$coachName - Leave (Half Day)'
              : '$coachName - Leave';

          for (final event in allEvents) {
            final eventDateStr = event.date.toIso8601String().split('T')[0];
            if (originalDateStrings.contains(eventDateStr) && 
                event.title == originalEventTitle) {
              try {
                await calendarService.deleteCalendarEvent(event.id);
              } catch (e) {
                debugPrint('Failed to delete calendar event ${event.id}: $e');
              }
            }
          }
        }

        if (mounted) {
          SuccessSnackbar.show(context, 'Whole leave request rejected');
        }
      }

      if (mounted) {
        ref.invalidate(requestListProvider);
        ref.invalidate(pendingRequestsCountProvider);
        ref.invalidate(calendarEventsProvider);
        ref.invalidate(calendarEventListProvider);
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(
          context,
          'Failed to process modification: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _handleReject(Request request) async {
    final confirm = await ConfirmationDialog.show(
      context,
      'Reject Request',
      'Are you sure you want to reject this request?',
      confirmText: 'Reject',
      cancelText: 'Cancel',
      icon: Icons.cancel_outlined,
      isDestructive: true,
    );

    if (confirm == true && mounted) {
      try {
        final requestService = ref.read(requestServiceProvider);
        await requestService.rejectRequest(request.id);

        if (mounted) {
          SuccessSnackbar.show(context, 'Request rejected');
          ref.invalidate(requestListProvider);
          ref.invalidate(pendingRequestsCountProvider);

          // Invalidate student/coach lists if registration request was rejected
          if (request.requestType == 'student_registration') {
            ref.invalidate(studentListProvider);
          } else if (request.requestType == 'coach_registration') {
            ref.invalidate(coachListProvider);
          }
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(
            context,
            'Failed to reject request: ${e.toString()}',
          );
        }
      }
    }
  }

  void _showRequestDetails(Request request, bool isDark) {
    // Extract leave-specific information
    String? coachName;
    String? leaveDates;
    bool isHalfDay = false;
    int? totalDays;
    String? originalLeaveDates;
    int? originalTotalDays;
    bool isModification = request.requestType == 'coach_leave_modification';
    
    if ((request.requestType == 'coach_leave' || request.requestType == 'coach_leave_modification') && request.metadata != null) {
      coachName = request.metadata!['coach_name'] as String?;
      
      if (isModification) {
        // Show both original and new dates for modifications
        isHalfDay = request.metadata!['new_is_half_day'] == true;
        totalDays = request.metadata!['new_total_days'] as int?;
        originalTotalDays = request.metadata!['original_total_days'] as int?;
        
        try {
          // Original dates
          if (request.metadata!['original_start_date'] != null && request.metadata!['original_end_date'] != null) {
            final startDate = DateTime.parse(request.metadata!['original_start_date']);
            final endDate = DateTime.parse(request.metadata!['original_end_date']);
            
            if (startDate.year == endDate.year && 
                startDate.month == endDate.month && 
                startDate.day == endDate.day) {
              originalLeaveDates = DateFormat('MMM dd, yyyy').format(startDate);
            } else {
              originalLeaveDates = '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}';
            }
            
            if (request.metadata!['original_is_half_day'] == true) {
              originalLeaveDates += ' (Half Day)';
            }
          }
          
          // New dates
          if (request.metadata!['new_start_date'] != null && request.metadata!['new_end_date'] != null) {
            final startDate = DateTime.parse(request.metadata!['new_start_date']);
            final endDate = DateTime.parse(request.metadata!['new_end_date']);
            
            if (startDate.year == endDate.year && 
                startDate.month == endDate.month && 
                startDate.day == endDate.day) {
              leaveDates = DateFormat('MMM dd, yyyy').format(startDate);
            } else {
              leaveDates = '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}';
            }
            
            if (isHalfDay) {
              leaveDates += ' (Half Day)';
            }
          }
        } catch (e) {
          // Handle parsing error
        }
      } else {
        // Regular leave request
        isHalfDay = request.metadata!['is_half_day'] == true;
        totalDays = request.metadata!['total_days'] as int?;
        
        try {
          if (request.metadata!['start_date'] != null && request.metadata!['end_date'] != null) {
            final startDate = DateTime.parse(request.metadata!['start_date']);
            final endDate = DateTime.parse(request.metadata!['end_date']);
            
            if (startDate.year == endDate.year && 
                startDate.month == endDate.month && 
                startDate.day == endDate.day) {
              leaveDates = DateFormat('MMM dd, yyyy').format(startDate);
            } else {
              leaveDates = '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}';
            }
            
            if (isHalfDay) {
              leaveDates += ' (Half Day)';
            }
          }
        } catch (e) {
          // Handle parsing error
        }
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.cardBackground
            : AppColorsLight.cardBackground,
        title: Text(
          request.title,
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(
                label: 'Type',
                value: _formatRequestType(request.requestType),
                isDark: isDark,
              ),
              // Show coach name for leave requests
              if (request.requestType == 'coach_leave' && coachName != null)
                _DetailRow(
                  label: 'Coach',
                  value: coachName,
                  isDark: isDark,
                ),
              _DetailRow(
                label: 'Status',
                value: request.status.toUpperCase(),
                isDark: isDark,
              ),
              _DetailRow(
                label: 'Created',
                value: DateFormat(
                  'MMM dd, yyyy • hh:mm a',
                ).format(request.createdAt),
                isDark: isDark,
              ),
              // Show leave dates for leave requests
              if ((request.requestType == 'coach_leave' || request.requestType == 'coach_leave_modification') && leaveDates != null) ...[
                const SizedBox(height: 8),
                if (isModification && originalLeaveDates != null) ...[
                  _DetailRow(
                    label: 'Original Dates',
                    value: originalLeaveDates,
                    isDark: isDark,
                  ),
                  if (originalTotalDays != null && originalTotalDays > 1)
                    _DetailRow(
                      label: 'Original Days',
                      value: '$originalTotalDays days',
                      isDark: isDark,
                    ),
                  const SizedBox(height: 4),
                  _DetailRow(
                    label: 'New Dates',
                    value: leaveDates,
                    isDark: isDark,
                  ),
                ] else ...[
                  _DetailRow(
                    label: 'Leave Dates',
                    value: leaveDates,
                    isDark: isDark,
                  ),
                ],
                if (totalDays != null && totalDays > 1)
                  _DetailRow(
                    label: isModification ? 'New Total Days' : 'Total Days',
                    value: '$totalDays days',
                    isDark: isDark,
                  ),
              ],
              // Show description (reason for leave)
              if (request.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  request.requestType == 'coach_leave' ? 'Reason' : 'Description',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.description!,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColorsLight.textPrimary,
                  ),
                ),
              ],
              // Show "invited by" info if available
              if (request.metadata != null &&
                  request.metadata!['invited_by'] == 'coach' &&
                  request.metadata!['inviter_name'] != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 16,
                      color: isDark ? AppColors.accent : AppColorsLight.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Invited by ${request.metadata!['inviter_name']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.accent
                            : AppColorsLight.accent,
                      ),
                    ),
                  ],
                ),
              ],
              if (request.responseMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Response',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.responseMessage!,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColorsLight.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? AppColors.accent : AppColorsLight.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRequestType(String type) {
    switch (type) {
      case 'student_registration':
        return 'Student Registration';
      case 'coach_registration':
        return 'Coach Registration';
      case 'coach_leave':
        return 'Coach Leave Request';
      case 'coach_leave_modification':
        return 'Coach Leave Modification';
      case 'batch_enrollment':
        return 'Batch Enrollment';
      default:
        return type
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) {
              return word[0].toUpperCase() + word.substring(1);
            })
            .join(' ');
    }
  }
}

class _RequestCard extends StatelessWidget {
  final Request request;
  final bool isDark;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _RequestCard({
    required this.request,
    required this.isDark,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      onTap: onView,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.accent : AppColorsLight.accent)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForType(request.requestType),
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(request.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColorsLight.textSecondary,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColorsLight.textSecondary,
              ),
            ),
          ],
          // Show "invited by" info if available
          if (request.metadata != null &&
              request.metadata!['invited_by'] == 'coach' &&
              request.metadata!['inviter_name'] != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                Icon(
                  Icons.person_add,
                  size: 14,
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  'Invited by ${request.metadata!['inviter_name']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.accent : AppColorsLight.accent,
                  ),
                ),
              ],
            ),
          ],
          if (request.isPending) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.error
                        : AppColorsLight.error,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.accent
                        : AppColorsLight.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'student_registration':
        return Icons.person_add;
      case 'coach_registration':
        return Icons.person_add_outlined;
      case 'coach_leave':
        return Icons.event_busy;
      case 'coach_leave_modification':
        return Icons.edit_calendar;
      case 'batch_enrollment':
        return Icons.group_add;
      default:
        return Icons.description;
    }
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
    final chipColor =
        color ?? (isDark ? AppColors.accent : AppColorsLight.accent);

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
                : (isDark
                      ? AppColors.textTertiary
                      : AppColorsLight.textTertiary),
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
                : (isDark
                      ? AppColors.textSecondary
                      : AppColorsLight.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColorsLight.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColorsLight.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
