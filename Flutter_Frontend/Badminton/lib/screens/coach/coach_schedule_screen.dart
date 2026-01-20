import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../models/schedule.dart';
import '../../core/utils/canadian_holidays.dart';

/// Coach Schedule Screen - Calendar-based view of batch schedules, operating days, and holidays
class CoachScheduleScreen extends ConsumerStatefulWidget {
  const CoachScheduleScreen({super.key});

  @override
  ConsumerState<CoachScheduleScreen> createState() => _CoachScheduleScreenState();
}

class _CoachScheduleScreenState extends ConsumerState<CoachScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Map<DateTime, List<Schedule>> _groupSessionsByDate(List<Schedule> sessions) {
    final Map<DateTime, List<Schedule>> grouped = {};
    for (var session in sessions) {
      final date = DateTime(session.date.year, session.date.month, session.date.day);
      grouped.putIfAbsent(date, () => []).add(session);
    }
    return grouped;
  }

  List<Schedule> _getSessionsForDay(DateTime day, Map<DateTime, List<Schedule>> groupedSessions) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return groupedSessions[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Schedule')),
            body: const Center(
              child: Text(
                'Please login',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          );
        }

        final coachId = authValue.userId;
        return _buildScaffold(coachId);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: const Center(child: DashboardSkeleton()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(int coachId) {
    final scheduleAsync = ref.watch(coachScheduleProvider(coachId));
    final batchesAsync = ref.watch(coachBatchesProvider(coachId));
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final eventsAsync = ref.watch(calendarEventsProvider(
      startDate: firstDay,
      endDate: lastDay,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(coachScheduleProvider(coachId));
          ref.invalidate(coachBatchesProvider(coachId));
          ref.invalidate(calendarEventsProvider(
            startDate: firstDay,
            endDate: lastDay,
          ));
        },
        child: scheduleAsync.when(
          loading: () => const Center(child: ListSkeleton(itemCount: 5)),
          error: (error, stack) => ErrorDisplay(
            message: 'Failed to load schedule',
            onRetry: () => ref.invalidate(coachScheduleProvider(coachId)),
          ),
          data: (sessions) {
            final groupedSessions = _groupSessionsByDate(sessions);
            final canadianHolidays = CanadianHolidays.getHolidaysForYear(_focusedDay.year);
            
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Calendar
                  NeumorphicContainer(
                    margin: const EdgeInsets.all(AppDimensions.paddingL),
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: TableCalendar<Schedule>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: (day) => _getSessionsForDay(day, groupedSessions),
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
                          
                          if (isSelected) return null;
                          
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
                          
                          return Positioned(
                            bottom: 1,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Selected Day Events
                  if (_getSessionsForDay(_selectedDay, groupedSessions).isNotEmpty ||
                      (canadianHolidays.containsKey(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)) &&
                       eventsAsync.valueOrNull != null)) ...[
                    NeumorphicContainer(
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          // Sessions
                          ..._getSessionsForDay(_selectedDay, groupedSessions).map((session) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                              child: _SessionCard(session: session),
                            ),
                          ),
                          // Holidays
                          if (canadianHolidays.containsKey(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day))) ...[
                            if (_getSessionsForDay(_selectedDay, groupedSessions).isNotEmpty)
                              const SizedBox(height: AppDimensions.spacingS),
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.paddingS),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event, color: Colors.red, size: 20),
                                  const SizedBox(width: AppDimensions.spacingS),
                                  Expanded(
                                    child: Text(
                                      canadianHolidays[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Calendar Events
                          if (eventsAsync.valueOrNull != null) ...[
                            ...eventsAsync.valueOrNull!.where((event) => 
                              isSameDay(event.date, _selectedDay)
                            ).map((event) => Padding(
                              padding: const EdgeInsets.only(top: AppDimensions.spacingS),
                              child: Container(
                                padding: const EdgeInsets.all(AppDimensions.paddingS),
                                decoration: BoxDecoration(
                                  color: event.eventType == 'holiday' 
                                      ? Colors.red.withOpacity(0.1)
                                      : event.eventType == 'tournament'
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      event.eventIcon,
                                      color: event.eventType == 'holiday' 
                                          ? Colors.red
                                          : event.eventType == 'tournament'
                                              ? Colors.blue
                                              : Colors.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppDimensions.spacingS),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: TextStyle(
                                              color: event.eventType == 'holiday' 
                                                  ? Colors.red
                                                  : event.eventType == 'tournament'
                                                      ? Colors.blue
                                                      : Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (event.description != null && event.description!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              event.description!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ],
                      ),
                    ),
                  ],
                  
                  // Batch Operating Days Info
                  batchesAsync.when(
                    data: (batches) {
                      if (batches.isEmpty) return const SizedBox.shrink();
                      
                      return NeumorphicContainer(
                        margin: const EdgeInsets.all(AppDimensions.paddingL),
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Batch Operating Days',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacingM),
                            ...batches.map((batch) => Padding(
                              padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      batch.batchName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    batch.period,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Schedule session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    // Session type color
    Color typeColor = AppColors.accent;
    String typeLabel = session.sessionType.toUpperCase();
    IconData typeIcon = Icons.sports_outlined;
    
    if (session.sessionType.toLowerCase() == 'tournament') {
      typeColor = AppColors.warning;
      typeIcon = Icons.emoji_events_outlined;
    } else if (session.sessionType.toLowerCase() == 'camp') {
      typeColor = AppColors.success;
      typeIcon = Icons.event_outlined;
    }

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(
                  typeIcon,
                  size: 20,
                  color: typeColor,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (session.batchName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        session.batchName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM, yyyy').format(session.date),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (session.startTime != null) ...[
                const SizedBox(width: AppDimensions.spacingM),
                Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${session.startTime}${session.endTime != null ? ' - ${session.endTime}' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (session.location != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.location!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (session.description != null && session.description!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              session.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
