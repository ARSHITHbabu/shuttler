import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/service_providers.dart';
import '../../models/calendar_event.dart';
import '../../core/utils/canadian_holidays.dart';
import 'package:intl/intl.dart';

/// Student Calendar Screen - Read-only calendar view
/// Shows all calendar events created by owner
/// Student can only view, cannot add/edit/delete events
class StudentCalendarScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentCalendarScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends ConsumerState<StudentCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Future<List<CalendarEvent>> _loadEvents() async {
    try {
      final calendarService = ref.read(calendarServiceProvider);
      // Get events for the current month
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      final events = await calendarService.getCalendarEvents(
        startDate: firstDay,
        endDate: lastDay,
      );
      return events;
    } catch (e) {
      return [];
    }
  }

  Map<DateTime, List<CalendarEvent>> _groupEventsByDate(List<CalendarEvent> events) {
    final Map<DateTime, List<CalendarEvent>> grouped = {};
    for (var event in events) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      grouped.putIfAbsent(date, () => []).add(event);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.background : AppColorsLight.background;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final cardBackground = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Calendar',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        // No add button - read-only for students
      ),
      body: FutureBuilder<List<CalendarEvent>>(
        future: _loadEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingSpinner());
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              message: 'Failed to load calendar events',
              onRetry: () => setState(() {}),
            );
          }

          final events = snapshot.data ?? [];
          final groupedEvents = _groupEventsByDate(events);
          
          // Get Canadian holidays for the focused year
          final canadianHolidays = CanadianHolidays.getHolidaysForYear(_focusedDay.year);

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
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    final date = DateTime(day.year, day.month, day.day);
                    return groupedEvents[date] ?? [];
                  },
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: textSecondary),
                    defaultTextStyle: TextStyle(color: textPrimary),
                    selectedDecoration: BoxDecoration(
                      color: isDark ? AppColors.accent : AppColorsLight.accent,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: (isDark ? AppColors.accent : AppColorsLight.accent).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: isDark ? AppColors.accent : AppColorsLight.accent,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    markerSize: 6,
                    canMarkersOverflow: true,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    formatButtonTextStyle: TextStyle(color: textPrimary),
                    leftChevronIcon: Icon(Icons.chevron_left, color: textPrimary),
                    rightChevronIcon: Icon(Icons.chevron_right, color: textPrimary),
                    titleTextStyle: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: textSecondary),
                    weekendStyle: TextStyle(color: textSecondary),
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
                    setState(() {
                      _focusedDay = focusedDay;
                      // This will trigger FutureBuilder to reload events
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, focusedDay) {
                      final dateKey = DateTime(date.year, date.month, date.day);
                      final isHoliday = canadianHolidays.containsKey(dateKey);
                      final isSelected = isSameDay(_selectedDay, date);
                      final isToday = isSameDay(DateTime.now(), date);
                      
                      if (isHoliday && !isSelected && !isToday) {
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
                      return null;
                    },
                    selectedBuilder: (context, date, focusedDay) {
                      final dateKey = DateTime(date.year, date.month, date.day);
                      final isHoliday = canadianHolidays.containsKey(dateKey);
                      
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isHoliday ? Colors.red : (isDark ? AppColors.accent : AppColorsLight.accent),
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
                      final dateKey = DateTime(date.year, date.month, date.day);
                      final isHoliday = canadianHolidays.containsKey(dateKey);
                      final isSelected = isSameDay(_selectedDay, date);
                      
                      if (isSelected) return null; // Let selectedBuilder handle it
                      
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isHoliday 
                              ? Colors.red.withOpacity(0.5)
                              : (isDark ? AppColors.accent : AppColorsLight.accent).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isHoliday ? Colors.red : textPrimary,
                            fontWeight: isHoliday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return null;
                      
                      final eventTypes = events.map((e) => (e).eventType).toSet();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: eventTypes.map((type) {
                          final event = events.firstWhere((e) => (e).eventType == type);
                          return Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: event.eventColor,
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),

              // Selected Day Events
              Expanded(
                child: _buildSelectedDayEvents(groupedEvents, isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayEvents(Map<DateTime, List<CalendarEvent>> groupedEvents, bool isDark) {
    final date = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final dayEvents = groupedEvents[date] ?? [];
    
    // Check if this is a Canadian holiday
    final holidayName = CanadianHolidays.getHolidayName(_selectedDay);
    final hasHoliday = holidayName != null;

    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Text(
            DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDay),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Expanded(
          child: (dayEvents.isEmpty && !hasHoliday)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 64,
                        color: textSecondary,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'No events on this day',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                    itemCount: (hasHoliday ? 1 : 0) + dayEvents.length,
                    itemBuilder: (context, index) {
                      // Show holiday first if it exists
                      if (hasHoliday && index == 0) {
                        return _buildHolidayCard(holidayName, isDark);
                      }
                      // Then show regular events
                      final eventIndex = hasHoliday ? index - 1 : index;
                      final event = dayEvents[eventIndex];
                      return _buildEventCard(event, isDark);
                    },
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildHolidayCard(String holidayName, bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Canadian Government Holiday',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
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

  Widget _buildEventCard(CalendarEvent event, bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    // No edit/delete buttons - read-only for students
                  ],
                ),
                if (event.description != null && event.description!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    event.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
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
}
