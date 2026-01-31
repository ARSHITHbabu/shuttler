import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/more_screen_app_bar.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';
import '../../core/utils/canadian_holidays.dart';
import 'package:intl/intl.dart';

/// Calendar View Screen - Visual calendar for events
/// Matches React reference: CalendarView.tsx
class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _showAddForm = false;
  bool _isLoading = false;
  CalendarEvent? _editingEvent; // Track if we're editing

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _eventDate;
  String _selectedEventType = 'holiday'; // 'holiday', 'tournament', 'event'

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Map<DateTime, List<CalendarEvent>> _groupEventsByDate(
    List<CalendarEvent> events,
  ) {
    final Map<DateTime, List<CalendarEvent>> grouped = {};
    for (var event in events) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      grouped.putIfAbsent(date, () => []).add(event);
    }
    return grouped;
  }

  void _editEvent(CalendarEvent event) {
    setState(() {
      _showAddForm = true;
      _editingEvent = event;
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _eventDate = event.date;
      _selectedEventType = event.eventType;
    });
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      SuccessSnackbar.showError(context, 'Please enter event title');
      return;
    }

    if (_eventDate == null) {
      SuccessSnackbar.showError(context, 'Please select event date');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Get current auth state from AsyncValue instead of waiting for future
      final authAsync = ref.read(authProvider);
      AuthState? authState = authAsync.value;

      // Fallback: If provider state is not available, try reading from authService directly
      if (authState == null) {
        final authService = ref.read(authServiceProvider);
        final storageService = ref.read(storageServiceProvider);

        // Ensure storage is initialized before checking login status
        if (!storageService.isInitialized) {
          await storageService.init();
        }

        final isLoggedIn = authService.isLoggedIn();

        if (isLoggedIn) {
          final userId = authService.getCurrentUserId();
          final userType = authService.getCurrentUserType();
          final userName = authService.getCurrentUserName();
          final userEmail = authService.getCurrentUserEmail();

          if (userId != null &&
              userType != null &&
              userName != null &&
              userEmail != null) {
            authState = Authenticated(
              userType: userType,
              userId: userId,
              userName: userName,
              userEmail: userEmail,
            );
          }
        }
      }

      // Validate authentication - created_by is required by backend
      if (authState == null) {
        // Auth state is still loading or not available
        setState(() => _isLoading = false);
        if (mounted) {
          SuccessSnackbar.showError(
            context,
            'Authentication state is loading. Please try again.',
          );
        }
        return;
      }

      if (authState is! Authenticated) {
        setState(() => _isLoading = false);
        if (mounted) {
          SuccessSnackbar.showError(
            context,
            'You must be logged in to create events',
          );
        }
        return;
      }

      // Validate userId is a valid positive integer
      final userId = authState.userId;
      if (userId <= 0) {
        setState(() => _isLoading = false);
        if (mounted) {
          SuccessSnackbar.showError(
            context,
            'Invalid user ID. Please log in again.',
          );
        }
        return;
      }

      // Determine creator_type based on userType
      String? creatorType;
      if (authState.userType == 'owner') {
        creatorType = 'owner';
      } else if (authState.userType == 'coach') {
        creatorType = 'coach';
      }

      // Validate creator_type
      if (creatorType == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          SuccessSnackbar.showError(
            context,
            'Unable to determine user type. Please try again.',
          );
        }
        return;
      }

      // Build event data and filter out null values
      final eventData = <String, dynamic>{
        'title': _titleController.text.trim(),
        'event_type': _selectedEventType,
        'date': _eventDate!.toIso8601String().split('T')[0],
        'created_by': userId, // Explicitly cast to int
        'creator_type': creatorType, // Add creator_type for backend validation
      };

      // Only add description if it's not empty
      final description = _descriptionController.text.trim();
      if (description.isNotEmpty) {
        eventData['description'] = description;
      }

      // Get events for current month to determine date range
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final calendarEventList = ref.read(
        calendarEventListProvider(
          startDate: firstDay,
          endDate: lastDay,
        ).notifier,
      );

      if (_editingEvent != null) {
        await calendarEventList.updateEvent(_editingEvent!.id, eventData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Event updated successfully');
        }
      } else {
        await calendarEventList.createEvent(eventData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Event created successfully');
        }
      }

      if (mounted) {
        setState(() {
          _showAddForm = false;
          _titleController.clear();
          _descriptionController.clear();
          _eventDate = null;
          _selectedEventType = 'holiday';
          _editingEvent = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SuccessSnackbar.showError(
          context,
          'Failed to ${_editingEvent != null ? 'update' : 'create'} event: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _deleteEvent(int id) async {
    final confirmed = await ConfirmationDialog.showDelete(context, 'Event');

    if (confirmed == true && mounted) {
      try {
        // Get events for current month to determine date range
        final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
        final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

        final calendarEventList = ref.read(
          calendarEventListProvider(
            startDate: firstDay,
            endDate: lastDay,
          ).notifier,
        );

        await calendarEventList.deleteEvent(id);
        if (mounted) {
          SuccessSnackbar.show(context, 'Event deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(
            context,
            'Failed to delete event: ${e.toString()}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      return _buildAddForm();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    void handleReload() {
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      ref.invalidate(
        calendarEventListProvider(startDate: firstDay, endDate: lastDay),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColorsLight.background,
      appBar: MoreScreenAppBar(
        title: 'Calendar',
        onReload: handleReload,
        isDark: isDark,
        additionalActions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? AppColors.accent : AppColorsLight.accent,
            ),
            onPressed: () => setState(() => _showAddForm = true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          handleReload();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: Consumer(
          builder: (context, ref, child) {
            // Get events for the current month
            final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
            final lastDay = DateTime(
              _focusedDay.year,
              _focusedDay.month + 1,
              0,
            );

            final eventsAsync = ref.watch(
              calendarEventListProvider(startDate: firstDay, endDate: lastDay),
            );

            return eventsAsync.when(
              loading: () => const Center(child: ListSkeleton(itemCount: 3)),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load calendar events: ${error.toString()}',
                onRetry: () => ref.invalidate(
                  calendarEventListProvider(
                    startDate: firstDay,
                    endDate: lastDay,
                  ),
                ),
              ),
              data: (events) {
                final groupedEvents = _groupEventsByDate(events);

                // Get Canadian holidays for the focused year
                final canadianHolidays = CanadianHolidays.getHolidaysForYear(
                  _focusedDay.year,
                );

                return Column(
                  children: [
                    // Calendar
                    NeumorphicContainer(
                      margin: const EdgeInsets.all(AppDimensions.paddingL),
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: TableCalendar<CalendarEvent>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                          CalendarFormat.twoWeeks: '2 Weeks',
                          CalendarFormat.week: 'Week',
                        },
                        eventLoader: (day) {
                          final date = DateTime(day.year, day.month, day.day);
                          return groupedEvents[date] ?? [];
                        },
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          weekendTextStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          defaultTextStyle: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          // Hide marker dots - using colored date numbers instead
                          markersMaxCount: 0,
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusS,
                            ),
                          ),
                          formatButtonTextStyle: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: AppColors.textPrimary,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textPrimary,
                          ),
                          titleTextStyle: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          weekendStyle: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() => _calendarFormat = format);
                        },
                        onPageChanged: (focusedDay) {
                          setState(() => _focusedDay = focusedDay);
                        },
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, date, focusedDay) {
                            final dateKey = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                            final isHoliday = canadianHolidays.containsKey(
                              dateKey,
                            );
                            final isSelected = isSameDay(_selectedDay, date);
                            final isToday = isSameDay(DateTime.now(), date);

                            // Check if events contain holiday type or non-holiday events
                            final hasHolidayEvent =
                                groupedEvents[dateKey]?.any(
                                  (e) => e.isHoliday,
                                ) ??
                                false;
                            final hasNonHolidayEvent =
                                groupedEvents[dateKey]?.any(
                                  (e) => !e.isHoliday,
                                ) ??
                                false;

                            if (!isSelected && !isToday) {
                              // Canadian holidays or holiday events - show in red
                              if (isHoliday || hasHolidayEvent) {
                                return Center(
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                              // Non-holiday events (tournament, event) - show in jade green
                              if (hasNonHolidayEvent) {
                                return Center(
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                      color: Color(0xFF00A86B), // Jade green
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                            }
                            return null;
                          },
                          selectedBuilder: (context, date, focusedDay) {
                            final dateKey = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                            final isHoliday = canadianHolidays.containsKey(
                              dateKey,
                            );
                            final hasHolidayEvent =
                                groupedEvents[dateKey]?.any(
                                  (e) => e.isHoliday,
                                ) ??
                                false;
                            final hasNonHolidayEvent =
                                groupedEvents[dateKey]?.any(
                                  (e) => !e.isHoliday,
                                ) ??
                                false;

                            Color bgColor = AppColors.accent;
                            if (isHoliday || hasHolidayEvent) {
                              bgColor = Colors.red;
                            } else if (hasNonHolidayEvent) {
                              bgColor = const Color(0xFF00A86B); // Jade green
                            }

                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          todayBuilder: (context, date, focusedDay) {
                            final dateKey = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                            final isHoliday = canadianHolidays.containsKey(
                              dateKey,
                            );
                            final hasHolidayEvent =
                                groupedEvents[dateKey]?.any(
                                  (e) => e.isHoliday,
                                ) ??
                                false;
                            final hasNonHolidayEvent =
                                groupedEvents[dateKey]?.any(
                                  (e) => !e.isHoliday,
                                ) ??
                                false;
                            final isSelected = isSameDay(_selectedDay, date);

                            if (isSelected) {
                              return null; // Let selectedBuilder handle it
                            }

                            Color bgColor = AppColors.accent.withValues(
                              alpha: 0.3,
                            );
                            Color textColor = AppColors.textPrimary;
                            FontWeight fontWeight = FontWeight.normal;

                            if (isHoliday || hasHolidayEvent) {
                              bgColor = Colors.red.withValues(alpha: 0.5);
                              textColor = Colors.red;
                              fontWeight = FontWeight.bold;
                            } else if (hasNonHolidayEvent) {
                              bgColor = const Color(
                                0xFF00A86B,
                              ).withValues(alpha: 0.3);
                              textColor = const Color(0xFF00A86B);
                              fontWeight = FontWeight.bold;
                            }

                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: fontWeight,
                                ),
                              ),
                            );
                          },
                          // No marker dots needed - using colored date numbers instead
                        ),
                      ),
                    ),

                    // Selected Day Events
                    Flexible(child: _buildSelectedDayEvents(groupedEvents)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDayEvents(
    Map<DateTime, List<CalendarEvent>> groupedEvents,
  ) {
    final date = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final dayEvents = groupedEvents[date] ?? [];

    // Check if this is a Canadian holiday
    final holidayName = CanadianHolidays.getHolidayName(_selectedDay);
    final hasHoliday = holidayName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Text(
            DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDay),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Expanded(
          child: (dayEvents.isEmpty && !hasHoliday)
              ? EmptyState.noEvents(
                  onAdd: () => setState(() => _showAddForm = true),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    shrinkWrap: false,
                    padding: EdgeInsets.only(
                      left: AppDimensions.paddingL,
                      right: AppDimensions.paddingL,
                      bottom:
                          AppDimensions.paddingL +
                          80, // Extra space for bottom nav
                    ),
                    itemCount: (hasHoliday ? 1 : 0) + dayEvents.length,
                    itemBuilder: (context, index) {
                      // Show holiday first if it exists
                      if (hasHoliday && index == 0) {
                        return _buildHolidayCard(holidayName);
                      }
                      // Then show regular events
                      final eventIndex = hasHoliday ? index - 1 : index;
                      final event = dayEvents[eventIndex];
                      return _buildEventCard(event);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHolidayCard(String holidayName) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.flag, size: 20, color: Colors.red),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holidayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Canadian Government Holiday',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: event.eventColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(event.eventIcon, size: 20, color: event.eventColor),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      color: AppColors.cardBackground,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Edit',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _editEvent(event);
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 18,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                          onTap: () => _deleteEvent(event.id),
                        ),
                      ],
                    ),
                  ],
                ),
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    event.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => setState(() => _showAddForm = false),
        ),
        title: Text(
          _editingEvent != null ? 'Edit Event' : 'Add Event',
          style: const TextStyle(
            color: AppColors.textPrimary,
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
              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Event Name',
                hint: 'Enter event name',
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Date
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _eventDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _eventDate = date);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        _eventDate != null
                            ? DateFormat('dd MMM, yyyy').format(_eventDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _eventDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Event Type
              const Text(
                'Event Type',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Row(
                children: [
                  Expanded(
                    child: _EventTypeButton(
                      label: 'Holiday',
                      value: 'holiday',
                      selected: _selectedEventType,
                      color: Colors.red,
                      onTap: () =>
                          setState(() => _selectedEventType = 'holiday'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: _EventTypeButton(
                      label: 'Tournament',
                      value: 'tournament',
                      selected: _selectedEventType,
                      color: Colors.blue,
                      onTap: () =>
                          setState(() => _selectedEventType = 'tournament'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: _EventTypeButton(
                      label: 'Event',
                      value: 'event',
                      selected: _selectedEventType,
                      color: Colors.green,
                      onTap: () => setState(() => _selectedEventType = 'event'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Enter description',
                maxLines: 3,
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingM,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _editingEvent != null ? 'Update Event' : 'Add Event',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}

class _EventTypeButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color color;
  final VoidCallback onTap;

  const _EventTypeButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
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
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
