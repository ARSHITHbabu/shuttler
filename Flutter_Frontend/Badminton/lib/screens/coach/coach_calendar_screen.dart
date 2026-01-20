import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../providers/service_providers.dart';
import '../../models/calendar_event.dart';
import '../../core/utils/canadian_holidays.dart';
import 'package:intl/intl.dart';

/// Coach Calendar Screen - Read-only calendar view
/// Shows all calendar events created by owner
/// Coach can only view, cannot add/edit/delete events
class CoachCalendarScreen extends ConsumerStatefulWidget {
  const CoachCalendarScreen({super.key});

  @override
  ConsumerState<CoachCalendarScreen> createState() => _CoachCalendarScreenState();
}

class _CoachCalendarScreenState extends ConsumerState<CoachCalendarScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        // No add button - read-only for coaches
      ),
      body: FutureBuilder<List<CalendarEvent>>(
        future: _loadEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ListSkeleton(itemCount: 5));
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
                    weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                    defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.accent,
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
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    formatButtonTextStyle: const TextStyle(color: AppColors.textPrimary),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                    titleTextStyle: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: AppColors.textSecondary),
                    weekendStyle: TextStyle(color: AppColors.textSecondary),
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
                          color: isHoliday ? Colors.red : AppColors.accent,
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
                              : AppColors.accent.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isHoliday ? Colors.red : AppColors.textPrimary,
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
                child: _buildSelectedDayEvents(groupedEvents),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayEvents(Map<DateTime, List<CalendarEvent>> groupedEvents) {
    final date = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final dayEvents = groupedEvents[date] ?? [];
    
    // Check if this is a Canadian holiday
    final holidayName = CanadianHolidays.getHolidayName(_selectedDay);
    final hasHoliday = holidayName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      const Text(
                        'No events on this day',
                        style: TextStyle(
                          color: AppColors.textSecondary,
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
                    // No edit/delete buttons - read-only for coaches
                  ],
                ),
                if (event.description != null && event.description!.isNotEmpty) ...[
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
}
