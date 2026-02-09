import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/calendar_event.dart';
import '../../models/schedule.dart';
import '../../core/utils/canadian_holidays.dart';
import 'package:intl/intl.dart';

enum ScheduleFilter { all, batches, holidays, tournaments, events }

/// Combined Student Schedule Screen
/// Shows calendar and events (batches, holidays, tournaments, events)
class StudentScheduleScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentScheduleScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends ConsumerState<StudentScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  ScheduleFilter _selectedFilter = ScheduleFilter.all;

  // Colors based on user requirements
  static const Color holidayColor = Colors.red;
  static const Color tournamentColor = Color(0xFFFF9800); // Orange
  static const Color eventColor = Color(0xFF00A86B); // Green
  static const Color batchColor = Colors.purple;

  Map<DateTime, List<dynamic>> _groupItemsByDate(List<CalendarEvent> events, List<Schedule> schedules) {
    final Map<DateTime, List<dynamic>> grouped = {};
    
    // Process events (holidays, tournaments, events)
    for (var event in events) {
      final startDate = DateTime(event.date.year, event.date.month, event.date.day);
      if (event.endDate != null) {
        final endDate = DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day);
        var currentDate = startDate;
        while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
          grouped.putIfAbsent(currentDate, () => []).add(event);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } else {
        grouped.putIfAbsent(startDate, () => []).add(event);
      }
    }

    // Process schedules (batches)
    for (var schedule in schedules) {
      final date = DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      grouped.putIfAbsent(date, () => []).add(schedule);
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
    final accentColor = isDark ? AppColors.accent : AppColorsLight.accent;

    final authState = ref.watch(authProvider).valueOrNull;
    if (authState is! Authenticated) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: Text('Please log in to view schedule')),
      );
    }

    final userId = authState.userId;
    final eventsAsync = ref.watch(yearlyEventsProvider(_focusedDay.year));
    final schedulesAsync = ref.watch(studentSchedulesProvider(userId));

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
          'Schedule',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(yearlyEventsProvider(_focusedDay.year));
          ref.invalidate(studentSchedulesProvider(userId));
        },
        child: eventsAsync.when(
          loading: () => const Center(child: DashboardSkeleton()),
          error: (error, stack) => ErrorDisplay(
            message: 'Failed to load events: ${error.toString()}',
            onRetry: () => ref.invalidate(yearlyEventsProvider(_focusedDay.year)),
          ),
          data: (events) {
            return schedulesAsync.when(
              loading: () => const Center(child: DashboardSkeleton()),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load schedules: ${error.toString()}',
                onRetry: () => ref.invalidate(studentSchedulesProvider(userId)),
              ),
              data: (schedules) {
                final groupedItems = _groupItemsByDate(events, schedules);
                final canadianHolidays = CanadianHolidays.getHolidaysForYear(_focusedDay.year);

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Calendar
                      NeumorphicContainer(
                        margin: const EdgeInsets.all(AppDimensions.paddingL),
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: TableCalendar<dynamic>(
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
                            return _getFilteredItems(groupedItems[date] ?? []);
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            weekendTextStyle: TextStyle(color: textSecondary),
                            defaultTextStyle: TextStyle(color: textPrimary),
                            selectedDecoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: accentColor.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 4,
                            markerDecoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
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
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, date, focusedDay) {
                              final dateKey = DateTime(date.year, date.month, date.day);
                              final isHoliday = canadianHolidays.containsKey(dateKey) || 
                                              events.any((e) => isSameDay(e.date, date) && e.isHoliday);
                              
                              if (isHoliday) {
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
                              final isHoliday = canadianHolidays.containsKey(dateKey) || 
                                              events.any((e) => isSameDay(e.date, date) && e.isHoliday);
                              
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isHoliday ? Colors.red.withOpacity(0.15) : accentColor,
                                  shape: BoxShape.circle,
                                  border: isHoliday ? Border.all(color: Colors.red, width: 1) : null,
                                ),
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: isHoliday ? Colors.red : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                            todayBuilder: (context, date, focusedDay) {
                              final dateKey = DateTime(date.year, date.month, date.day);
                              final isHoliday = canadianHolidays.containsKey(dateKey) || 
                                              events.any((e) => isSameDay(e.date, date) && e.isHoliday);
                              
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: isHoliday ? Border.all(color: Colors.red, width: 1) : null,
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
                              
                              final dateKey = DateTime(date.year, date.month, date.day);
                              final hasholiday = canadianHolidays.containsKey(dateKey) || 
                                events.any((e) => e is CalendarEvent && e.isHoliday);
                              final hasTournament = events.any((e) => e is CalendarEvent && e.eventType.toLowerCase() == 'tournament');
                              final hasEvent = events.any((e) => e is CalendarEvent && e.eventType.toLowerCase() == 'event');
                              final hasBatch = events.any((e) => e is Schedule);

                              List<Widget> markers = [];
                              if (hasholiday) markers.add(_buildMarkerCircle(holidayColor));
                              if (hasTournament) markers.add(_buildMarkerCircle(tournamentColor));
                              if (hasEvent) markers.add(_buildMarkerCircle(eventColor));
                              if (hasBatch) markers.add(_buildMarkerCircle(batchColor));

                              return Positioned(
                                bottom: 1,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: markers.map((m) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 1),
                                    child: m,
                                  )).toList(),
                                ),
                              );
                            },
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
                        ),
                      ),

                      // Filter Options
                      _buildFilters(isDark),

                      const SizedBox(height: AppDimensions.spacingM),

                      // Selected Day Content
                      _buildSelectedDayContent(groupedItems, canadianHolidays, isDark),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarkerCircle(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  List<dynamic> _getFilteredItems(List<dynamic> items) {
    if (_selectedFilter == ScheduleFilter.all) return items;
    
    return items.where((item) {
      if (item is Schedule) return _selectedFilter == ScheduleFilter.batches;
      if (item is CalendarEvent) {
        if (item.isHoliday) return _selectedFilter == ScheduleFilter.holidays;
        if (item.eventType.toLowerCase() == 'tournament') return _selectedFilter == ScheduleFilter.tournaments;
        if (item.eventType.toLowerCase() == 'event') return _selectedFilter == ScheduleFilter.events;
      }
      return false;
    }).toList();
  }

  Widget _buildFilters(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Row(
        children: [
          _buildFilterChip('All', ScheduleFilter.all, isDark),
          _buildFilterChip('Batches', ScheduleFilter.batches, isDark),
          _buildFilterChip('Holidays', ScheduleFilter.holidays, isDark),
          _buildFilterChip('Tournaments', ScheduleFilter.tournaments, isDark),
          _buildFilterChip('Events', ScheduleFilter.events, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ScheduleFilter filter, bool isDark) {
    final isSelected = _selectedFilter == filter;
    final accentColor = isDark ? AppColors.accent : AppColorsLight.accent;
    final cardBg = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;
    final textP = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingS),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : textP,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayContent(Map<DateTime, List<dynamic>> groupedItems, Map<DateTime, String> canadianHolidays, bool isDark) {
    final date = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final items = _getFilteredItems(groupedItems[date] ?? []);
    final holidayName = CanadianHolidays.getHolidayName(date);
    
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;

    // Check if we should show holiday if filter is All or Holidays
    final showHoliday = (holidayName != null) && 
        (_selectedFilter == ScheduleFilter.all || _selectedFilter == ScheduleFilter.holidays);

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDay),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          if (items.isEmpty && !showHoliday)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('No entries for this date'),
            ))
          else
            _buildGroupedList(items, holidayName, isDark),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<dynamic> items, String? holidayName, bool isDark) {
    final batches = items.whereType<Schedule>().toList();
    final tournaments = items.whereType<CalendarEvent>().where((e) => e.eventType.toLowerCase() == 'tournament').toList();
    final events = items.whereType<CalendarEvent>().where((e) => e.eventType.toLowerCase() == 'event').toList();
    final holidays = items.whereType<CalendarEvent>().where((e) => e.isHoliday).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedFilter == ScheduleFilter.all || _selectedFilter == ScheduleFilter.batches)
          if (batches.isNotEmpty) ...[
            _buildSectionHeader('Batches', batchColor, isDark),
            ...batches.map((b) => _buildBatchCard(b, isDark)),
            const SizedBox(height: AppDimensions.spacingL),
          ],

        if (_selectedFilter == ScheduleFilter.all || _selectedFilter == ScheduleFilter.holidays)
          if (holidays.isNotEmpty || holidayName != null) ...[
            _buildSectionHeader('Holidays', holidayColor, isDark),
            if (holidayName != null) _buildSimpleCard(holidayName, 'Canadian Government Holiday', holidayColor, Icons.celebration, isDark),
            ...holidays.map((h) => _buildSimpleCard(h.title, h.description ?? 'Academy Holiday', holidayColor, Icons.celebration, isDark)),
            const SizedBox(height: AppDimensions.spacingL),
          ],

        if (_selectedFilter == ScheduleFilter.all || _selectedFilter == ScheduleFilter.tournaments)
          if (tournaments.isNotEmpty) ...[
            _buildSectionHeader('Tournaments', tournamentColor, isDark),
            ...tournaments.map((t) => _buildSimpleCard(t.title, t.description ?? '', tournamentColor, Icons.emoji_events, isDark)),
            const SizedBox(height: AppDimensions.spacingL),
          ],

        if (_selectedFilter == ScheduleFilter.all || _selectedFilter == ScheduleFilter.events)
          if (events.isNotEmpty) ...[
            _buildSectionHeader('Events', eventColor, isDark),
            ...events.map((e) => _buildSimpleCard(e.title, e.description ?? '', eventColor, Icons.event, isDark)),
            const SizedBox(height: AppDimensions.spacingL),
          ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(Schedule schedule, bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: batchColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sports_tennis, color: batchColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.batchName ?? 'Training Session',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
                ),
                Text(
                  '${schedule.startTime ?? ""} - ${schedule.endTime ?? ""}',
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
                if (schedule.location != null)
                  Text(
                    schedule.location!,
                    style: TextStyle(fontSize: 12, color: textSecondary, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard(String title, String subtitle, Color color, IconData icon, bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
