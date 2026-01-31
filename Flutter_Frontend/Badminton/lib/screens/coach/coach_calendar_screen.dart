import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/more_screen_app_bar.dart';
import '../../providers/calendar_provider.dart';
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
    
    void _handleReload() {
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      ref.invalidate(calendarEventsProvider(
        startDate: firstDay,
        endDate: lastDay,
      ));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: MoreScreenAppBar(
        title: 'Calendar',
        onReload: _handleReload,
        isDark: isDark,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _handleReload();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: _buildCalendarBody(),
      ),
    );
  }

  Widget _buildCalendarBody() {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final eventsAsync = ref.watch(calendarEventsProvider(
      startDate: firstDay,
      endDate: lastDay,
    ));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
        child: eventsAsync.when(
          loading: () => const Center(child: ListSkeleton(itemCount: 5)),
          error: (error, stack) => ErrorDisplay(
            message: 'Failed to load calendar events: ${error.toString()}',
            onRetry: () => ref.invalidate(calendarEventsProvider(
              startDate: firstDay,
              endDate: lastDay,
            )),
          ),
          data: (events) {
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
                    // Hide marker dots - using colored date numbers instead
                    markersMaxCount: 0,
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
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, focusedDay) {
                      final dateKey = DateTime(date.year, date.month, date.day);
                      final isHoliday = canadianHolidays.containsKey(dateKey);
                      final isSelected = isSameDay(_selectedDay, date);
                      final isToday = isSameDay(DateTime.now(), date);

                      // Check if events contain holiday type
                      final hasHolidayEvent = groupedEvents[dateKey]?.any((e) => e.isHoliday) ?? false;
                      final hasNonHolidayEvent = groupedEvents[dateKey]?.any((e) => !e.isHoliday) ?? false;

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
                      final dateKey = DateTime(date.year, date.month, date.day);
                      final isHoliday = canadianHolidays.containsKey(dateKey);
                      final hasHolidayEvent = groupedEvents[dateKey]?.any((e) => e.isHoliday) ?? false;
                      final hasNonHolidayEvent = groupedEvents[dateKey]?.any((e) => !e.isHoliday) ?? false;

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
                      final dateKey = DateTime(date.year, date.month, date.day);
                      final isHoliday = canadianHolidays.containsKey(dateKey);
                      final hasHolidayEvent = groupedEvents[dateKey]?.any((e) => e.isHoliday) ?? false;
                      final hasNonHolidayEvent = groupedEvents[dateKey]?.any((e) => !e.isHoliday) ?? false;
                      final isSelected = isSameDay(_selectedDay, date);

                      if (isSelected) return null; // Let selectedBuilder handle it

                      Color bgColor = AppColors.accent.withOpacity(0.3);
                      Color textColor = AppColors.textPrimary;
                      FontWeight fontWeight = FontWeight.normal;

                      if (isHoliday || hasHolidayEvent) {
                        bgColor = Colors.red.withOpacity(0.5);
                        textColor = Colors.red;
                        fontWeight = FontWeight.bold;
                      } else if (hasNonHolidayEvent) {
                        bgColor = const Color(0xFF00A86B).withOpacity(0.3);
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
              _buildSelectedDayEvents(groupedEvents),
            ],
          );
          },
        ),
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
        if (dayEvents.isEmpty && !hasHoliday)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: EmptyState.noEvents(),
          )
        else ...[
          if (hasHoliday) Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: _buildHolidayCard(holidayName),
          ),
          ...dayEvents.map((event) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: _buildEventCard(event),
              )),
        ],
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
