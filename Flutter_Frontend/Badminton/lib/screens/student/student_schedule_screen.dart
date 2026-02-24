import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/batch_provider.dart';
import '../../models/schedule.dart';
import '../../models/batch.dart';

/// Student Schedule Screen - READ-ONLY view of practice session schedules
/// Students can view their batch schedules and upcoming practice sessions
class StudentScheduleScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentScheduleScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends ConsumerState<StudentScheduleScreen> {
  int? _selectedBatchId;
  DateTime _selectedDate = DateTime.now();

  // Calendar view mode
  bool _showCalendarView = true;

  List<Schedule> _filterSchedules(List<Schedule> schedules) {
    if (_selectedBatchId == null) {
      return schedules;
    }
    return schedules.where((s) => s.batchId == _selectedBatchId).toList();
  }

  List<Schedule> _getSchedulesForDay(List<Schedule> schedules, DateTime date) {
    // For now, return all schedules for the selected date
    // In a real implementation, you'd filter by day of week from batch schedule
    return schedules.where((schedule) {
      return schedule.date.year == date.year &&
             schedule.date.month == date.month &&
             schedule.date.day == date.day;
    }).toList();
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get user ID from auth provider
    final authStateAsync = ref.watch(authProvider);
    
    return authStateAsync.when(
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: ListSkeleton(itemCount: 5)),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ErrorDisplay(
          message: 'Failed to load user data: ${error.toString()}',
          onRetry: () => ref.invalidate(authProvider),
        ),
      ),
      data: (authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: ErrorDisplay(
              message: 'Please log in to view schedule',
              onRetry: () => ref.invalidate(authProvider),
            ),
          );
        }

        final userId = authState.userId;
        final schedulesAsync = ref.watch(studentSchedulesProvider(userId));
        final batchesAsync = ref.watch(studentBatchesProvider(userId));

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studentSchedulesProvider(userId));
              ref.invalidate(studentBatchesProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  leading: widget.onBack != null
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                          ),
                          onPressed: widget.onBack,
                        )
                      : null,
                  title: Text(
                    'My Schedule',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(
                        _showCalendarView ? Icons.view_list : Icons.calendar_month,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showCalendarView = !_showCalendarView;
                        });
                      },
                    ),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: schedulesAsync.when(
                    loading: () => const SizedBox(
                      height: 400,
                      child: ListSkeleton(itemCount: 5),
                    ),
                    error: (error, stack) => ErrorDisplay(
                      message: 'Failed to load schedule: ${error.toString()}',
                      onRetry: () => ref.invalidate(studentSchedulesProvider(userId)),
                    ),
                    data: (schedules) {
                      final filteredSchedules = _filterSchedules(schedules);
                      
                      return batchesAsync.when(
                        data: (batches) => Column(
                          children: [
                            // Batch Filter
                            if (batches.isNotEmpty) ...[
                              _buildBatchFilter(isDark, batches),
                              const SizedBox(height: AppDimensions.spacingM),
                            ],

                            // Calendar or List View
                            if (_showCalendarView)
                              _buildCalendarView(isDark, filteredSchedules)
                            else
                              _buildListView(isDark, filteredSchedules),
                          ],
                        ),
                        loading: () => const SizedBox(
                          height: 200,
                          child: ListSkeleton(itemCount: 3),
                        ),
                        error: (error, stack) => Column(
                          children: [
                            if (filteredSchedules.isEmpty)
                              EmptyState.noEvents()
                            else
                              _showCalendarView
                                  ? _buildCalendarView(isDark, filteredSchedules)
                                  : _buildListView(isDark, filteredSchedules),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatchFilter(bool isDark, List<Batch> batches) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All Batches',
              isSelected: _selectedBatchId == null,
              isDark: isDark,
              onTap: () => setState(() => _selectedBatchId = null),
            ),
            ...batches.map((batch) {
              return Padding(
                padding: const EdgeInsets.only(left: AppDimensions.spacingS),
                child: _FilterChip(
                  label: batch.name,
                  isSelected: _selectedBatchId == batch.id,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedBatchId = batch.id),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(bool isDark, List<Schedule> schedules) {
    return Column(
      children: [
        // Week Navigation
        _buildWeekNavigation(isDark),

        const SizedBox(height: AppDimensions.spacingM),

        // Week Days
        _buildWeekDays(isDark, schedules),

        const SizedBox(height: AppDimensions.spacingL),

        // Selected Day Practice Sessions
        _buildSelectedDaySessions(isDark, schedules),
      ],
    );
  }

  Widget _buildWeekNavigation(bool isDark) {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
              ),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                });
              },
            ),
            Column(
              children: [
                Text(
                  '${months[startOfWeek.month - 1]} ${startOfWeek.day} - ${months[endOfWeek.month - 1]} ${endOfWeek.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                Text(
                  startOfWeek.year.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
              ),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 7));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDays(bool isDark, List<Schedule> schedules) {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final isToday = date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year;
          final hasSession = _getSchedulesForDay(schedules, date).isNotEmpty;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.accent : AppColorsLight.accent)
                    : isToday
                        ? (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.2)
                        : null,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasSession)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.success : AppColorsLight.success),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedDaySessions(bool isDark, List<Schedule> schedules) {
    final sessions = _getSchedulesForDay(schedules, _selectedDate);
    final dayName = _getDayName(_selectedDate.weekday);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dayName Practice Sessions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),

          if (sessions.isEmpty)
            EmptyState.noEvents()
          else
            ...sessions.map((session) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                  child: _ScheduleCard(
                    schedule: session,
                    isDark: isDark,
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildListView(bool isDark, List<Schedule> schedules) {
    if (schedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: EmptyState.noEvents(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),

          ...schedules.map((schedule) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                child: _ScheduleCard(
                  schedule: schedule,
                  isDark: isDark,
                  showDays: true,
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.accent : AppColorsLight.accent)
              : (isDark ? AppColors.cardBackground : AppColorsLight.cardBackground),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: isSelected ? null : NeumorphicStyles.getElevatedShadow(),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final bool isDark;
  final bool showDays;

  const _ScheduleCard({
    required this.schedule,
    required this.isDark,
    this.showDays = false,
  });

  @override
  Widget build(BuildContext context) {
    final batchName = schedule.batchName ?? 'Practice Session';
    final startTime = schedule.startTime ?? '';
    final endTime = schedule.endTime ?? '';
    final location = schedule.location ?? '';
    final activityType = schedule.sessionType;
    final notes = schedule.description ?? '';
    final coachName = schedule.coachName ?? '';

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  Icons.sports_tennis,
                  size: 24,
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batchName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      activityType,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Details
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColorsLight.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              boxShadow: NeumorphicStyles.getSmallInsetShadow(),
            ),
            child: Column(
              children: [
                if (startTime.isNotEmpty) ...[
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: endTime.isNotEmpty ? '$startTime - $endTime' : startTime,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                ],
                if (location.isNotEmpty)
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: location,
                    isDark: isDark,
                  ),
                if (coachName.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  _DetailRow(
                    icon: Icons.person,
                    label: 'Coach',
                    value: coachName,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),

          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes,
                  size: 14,
                  color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    notes,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
