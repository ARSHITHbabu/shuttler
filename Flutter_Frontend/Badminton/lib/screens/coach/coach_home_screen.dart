import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/batch_provider.dart';
import '../../models/schedule.dart';
import '../../widgets/forms/add_student_dialog.dart';
import 'coach_schedule_screen.dart';
import 'coach_students_screen.dart';
import 'coach_attendance_screen.dart';
import '../../core/utils/canadian_holidays.dart';

/// Coach Home Screen - Dashboard overview
/// Shows coach's assigned batches, today's sessions, and quick stats
class CoachHomeScreen extends ConsumerStatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  ConsumerState<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends ConsumerState<CoachHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return Center(
            child: Text(
              'Please login',
              style: TextStyle(color: context.errorColor),
            ),
          );
        }

        final coachId = authValue.userId;
        return _buildContent(coachId, authValue.userName);
      },
      loading: () => const Center(child: DashboardSkeleton()),
      error: (error, stack) => Center(
        child: Text(
          'Error: ${error.toString()}',
          style: TextStyle(color: context.errorColor),
        ),
      ),
    );
  }

  Widget _buildContent(int coachId, String coachName) {

    final coachStatsAsync = ref.watch(coachStatsProvider(coachId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(coachStatsProvider(coachId));
        ref.invalidate(coachUpcomingSessionsProvider(coachId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coachName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  // Holiday Indicator
                  if (CanadianHolidays.isHoliday(DateTime.now())) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(color: context.errorColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.celebration, size: 16, color: context.errorColor),
                          const SizedBox(width: 8),
                          Text(
                            CanadianHolidays.getHolidayName(DateTime.now())!,
                            style: TextStyle(
                              color: context.errorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Stats Grid
            coachStatsAsync.when(
              data: (stats) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppDimensions.spacingM,
                  mainAxisSpacing: AppDimensions.spacingM,
                  childAspectRatio: 0.85,
                  children: [
                    _StatCard(
                      icon: Icons.people_outline,
                      value: stats.totalStudents.toString(),
                      label: 'Total Students',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CoachStudentsScreen(),
                          ),
                        );
                      },
                    ),
                    _StatCard(
                      icon: Icons.trending_up,
                      value: '${stats.attendanceRate.toStringAsFixed(0)}%',
                      label: 'Attendance Rate',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CoachAttendanceScreen(
                              initialMode: AttendanceViewMode.personal,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                child: GridSkeleton(itemCount: 2, crossAxisCount: 2),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: ErrorDisplay(
                  message: 'Failed to load statistics',
                  onRetry: () => ref.invalidate(coachStatsProvider(coachId)),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Upcoming Sessions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  ref.watch(coachUpcomingSessionsProvider(coachId)).when(
                        data: (sessions) => NeumorphicContainer(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          child: sessions.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(AppDimensions.spacingM),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.event_available,
                                          size: 48,
                                          color: context.textTertiaryColor,
                                        ),
                                        const SizedBox(height: AppDimensions.spacingM),
                                        Text(
                                          'No upcoming sessions',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: context.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: sessions.asMap().entries.map((entry) {
                                    final session = entry.value;
                                    final isLast = entry.key == sessions.length - 1;
                                    return Column(
                                      children: [
                                        _UpcomingSessionItem(
                                          name: session['batch_name'] ?? 'Unknown Batch',
                                          time: session['time'] ?? '',
                                          location: session['location'] ?? '',
                                          date: session['date'] != null 
                                            ? _formatSessionDate(DateTime.parse(session['date']))
                                            : null,
                                        ),
                                        if (!isLast)
                                          Divider(
                                            color: context.surfaceLightColor,
                                            height: AppDimensions.spacingL,
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                        ),
                        loading: () => const NeumorphicContainer(
                          padding: EdgeInsets.all(AppDimensions.paddingM),
                          child: ListSkeleton(itemCount: 3),
                        ),
                        error: (error, stack) => const SizedBox.shrink(),
                      ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add,
                          label: 'Add Student',
                          onTap: () => _showAddStudentDialog(context),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.calendar_today_outlined,
                          label: 'View Schedule',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CoachScheduleScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) return 'Today';
    if (sessionDate == tomorrow) return 'Tomorrow';
    
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddStudentDialog(),
    );
  }

  Color _getSessionStatusColor(Schedule session, BuildContext context) {
    final now = DateTime.now();
    final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (sessionDate.isBefore(today)) {
      return context.textSecondaryColor; // Completed
    } else if (sessionDate.isAtSameMomentAs(today)) {
      // Check if session time has passed
      if (session.startTime != null) {
        final timeParts = session.startTime!.split(':');
        if (timeParts.length >= 2) {
          final sessionHour = int.tryParse(timeParts[0]) ?? 0;
          final sessionMinute = int.tryParse(timeParts[1]) ?? 0;
          final sessionDateTime = DateTime(now.year, now.month, now.day, sessionHour, sessionMinute);
          
          if (now.isAfter(sessionDateTime)) {
            return context.successColor; // Ongoing
          }
        }
      }
      return context.accentColor; // Upcoming
    } else {
      return context.accentColor; // Upcoming
    }
  }

  String _getSessionStatus(Schedule session) {
    final now = DateTime.now();
    final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (sessionDate.isBefore(today)) {
      return 'completed';
    } else if (sessionDate.isAtSameMomentAs(today)) {
      if (session.startTime != null) {
        final timeParts = session.startTime!.split(':');
        if (timeParts.length >= 2) {
          final sessionHour = int.tryParse(timeParts[0]) ?? 0;
          final sessionMinute = int.tryParse(timeParts[1]) ?? 0;
          final sessionDateTime = DateTime(now.year, now.month, now.day, sessionHour, sessionMinute);
          
          if (now.isAfter(sessionDateTime)) {
            return 'ongoing';
          }
        }
      }
      return 'upcoming';
    } else {
      return 'upcoming';
    }
  }
}

class _UpcomingSessionItem extends StatelessWidget {
  final String name;
  final String time;
  final String location;
  final String? date;

  const _UpcomingSessionItem({
    required this.name,
    required this.time,
    required this.location,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: NeumorphicStyles.getInsetShadow(),
          ),
          child: Icon(
            Icons.sports_tennis,
            size: 20,
            color: context.accentColor,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  if (date != null)
                    Text(
                      date!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.accentColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondaryColor,
                ),
              ),
              if (location.isNotEmpty)
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textTertiaryColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  boxShadow: NeumorphicStyles.getInsetShadow(),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: context.iconPrimaryColor,
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: context.textTertiaryColor,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondaryColor,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return onTap != null
        ? GestureDetector(
            onTap: onTap,
            child: card,
          )
        : card;
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: context.iconPrimaryColor,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: context.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
