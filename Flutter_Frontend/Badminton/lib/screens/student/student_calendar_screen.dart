import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../providers/calendar_provider.dart';
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

  Map<DateTime, List<CalendarEvent>> _groupEventsByDate(List<CalendarEvent> events) {
    final Map<DateTime, List<CalendarEvent>> grouped = {};
    for (var event in events) {
      final startDate = DateTime(event.date.year, event.date.month, event.date.day);
      
      // If event has an end date (date range), add it to all days in the range
      if (event.endDate != null) {
        final endDate = DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day);
        var currentDate = startDate;
        while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
          grouped.putIfAbsent(currentDate, () => []).add(event);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } else {
        // Single day event
        grouped.putIfAbsent(startDate, () => []).add(event);
      }
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
      body: Builder(
        builder: (context) {
          // Get events for the current year
          final eventsAsync = ref.watch(yearlyEventsProvider(_focusedDay.year));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(yearlyEventsProvider(_focusedDay.year));
            },
            child: eventsAsync.when(
              loading: () => const Center(child: DashboardSkeleton()),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load calendar events: ${error.toString()}',
                onRetry: () => ref.invalidate(yearlyEventsProvider(_focusedDay.year)),
              ),
              data: (events) {
                final groupedEvents = _groupEventsByDate(events);
                
                // Get Canadian holidays for the focused year
                final canadianHolidays = CanadianHolidays.getHolidaysForYear(_focusedDay.year);

                return SingleChildScrollView(
                  child: Column(
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
                            // Hide marker dots - using colored date numbers instead
                            markersMaxCount: 0,
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
                              // Provider will automatically reload events for new month
                            });
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, date, focusedDay) {
                              final dateKey = DateTime(date.year, date.month, date.day);
                              final isHoliday = canadianHolidays.containsKey(dateKey);
                              final isSelected = isSameDay(_selectedDay, date);
                              final isToday = isSameDay(DateTime.now(), date);

                              // Check if events contain holiday type or non-holiday events
                              final hasHolidayEvent = groupedEvents[dateKey]?.any((e) => e.isHoliday) ?? false;
                              final hasLeaveEvent = groupedEvents[dateKey]?.any((e) => e.isLeave) ?? false;
                              final hasOtherEvent = groupedEvents[dateKey]?.any((e) => !e.isHoliday && !e.isLeave) ?? false;

                              if (!isSelected && !isToday) {
                                // Canadian holidays or holiday events - show in red (highest priority)
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
                                // Leave events - show in orange/amber
                                if (hasLeaveEvent) {
                                  return Center(
                                    child: Text(
                                      '${date.day}',
                                      style: const TextStyle(
                                        color: Color(0xFFFF9800), // Orange/Amber
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                // Other events (tournament, event) - show in jade green
                                if (hasOtherEvent) {
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
                              final dateKey = DateTime(date.year, date.month, date.day);
                              final isHoliday = canadianHolidays.containsKey(dateKey);
                              final hasHolidayEvent = groupedEvents[dateKey]?.any((e) => e.isHoliday) ?? false;
                              final hasLeaveEvent = groupedEvents[dateKey]?.any((e) => e.isLeave) ?? false;
                              final hasOtherEvent = groupedEvents[dateKey]?.any((e) => !e.isHoliday && !e.isLeave) ?? false;

                              Color bgColor = isDark ? AppColors.accent : AppColorsLight.accent;
                              if (isHoliday || hasHolidayEvent) {
                                bgColor = Colors.red;
                              } else if (hasLeaveEvent) {
                                bgColor = const Color(0xFFFF9800); // Orange/Amber
                              } else if (hasOtherEvent) {
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
                              final dateKey = DateTime(date.year, date.month, date.day);
                              final isHoliday = canadianHolidays.containsKey(dateKey);
                              final hasHolidayEvent = groupedEvents[dateKey]?.any((e) => e.isHoliday) ?? false;
                              final hasLeaveEvent = groupedEvents[dateKey]?.any((e) => e.isLeave) ?? false;
                              final hasOtherEvent = groupedEvents[dateKey]?.any((e) => !e.isHoliday && !e.isLeave) ?? false;
                              final isSelected = isSameDay(_selectedDay, date);

                              if (isSelected) return null; // Let selectedBuilder handle it

                              Color bgColor = (isDark ? AppColors.accent : AppColorsLight.accent).withOpacity(0.3);
                              Color textColorValue = textPrimary;
                              FontWeight fontWeight = FontWeight.normal;

                              if (isHoliday || hasHolidayEvent) {
                                bgColor = Colors.red.withOpacity(0.5);
                                textColorValue = Colors.red;
                                fontWeight = FontWeight.bold;
                              } else if (hasLeaveEvent) {
                                bgColor = const Color(0xFFFF9800).withOpacity(0.3);
                                textColorValue = const Color(0xFFFF9800);
                                fontWeight = FontWeight.bold;
                              } else if (hasOtherEvent) {
                                bgColor = const Color(0xFF00A86B).withOpacity(0.3);
                                textColorValue = const Color(0xFF00A86B);
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
                                    color: textColorValue,
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
                      _buildSelectedDayEvents(groupedEvents, isDark),
                    ],
                  ),
                );
              },
            ),
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
        if (dayEvents.isEmpty && !hasHoliday)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: EmptyState.noEvents(),
          )
        else ...[
          if (hasHoliday) _buildHolidayCard(holidayName, isDark),
          ...dayEvents.map((event) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: _buildEventCard(event, isDark),
              )),
        ],
        const SizedBox(height: AppDimensions.spacingL),
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
                const Icon(Icons.celebration, size: 20, color: Colors.red),
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
