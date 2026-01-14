import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/schedule.dart';

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
          return const Center(
            child: Text(
              'Please login',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        final coachId = authValue.userId;
        return _buildContent(coachId, authValue.userName);
      },
      loading: () => const Center(child: LoadingSpinner()),
      error: (error, stack) => Center(
        child: Text(
          'Error: ${error.toString()}',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(int coachId, String coachName) {

    final coachStatsAsync = ref.watch(coachStatsProvider(coachId));
    final todaySessionsAsync = ref.watch(coachTodaySessionsProvider(coachId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(coachStatsProvider(coachId));
        ref.invalidate(coachTodaySessionsProvider(coachId));
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
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coachName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
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
                  childAspectRatio: 1.1,
                  children: [
                    _StatCard(
                      icon: Icons.groups,
                      value: stats.assignedBatches.toString(),
                      label: 'Assigned Batches',
                      onTap: null,
                    ),
                    _StatCard(
                      icon: Icons.people_outline,
                      value: stats.totalStudents.toString(),
                      label: 'Total Students',
                      onTap: null,
                    ),
                    _StatCard(
                      icon: Icons.calendar_today_outlined,
                      value: stats.sessionsToday.toString(),
                      label: 'Sessions Today',
                      onTap: null,
                    ),
                    _StatCard(
                      icon: Icons.trending_up,
                      value: '${stats.attendanceRate.toStringAsFixed(0)}%',
                      label: 'Attendance Rate',
                      onTap: null,
                    ),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                child: Center(child: LoadingSpinner()),
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

            // Today's Sessions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Sessions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  todaySessionsAsync.when(
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return NeumorphicContainer(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          child: const Center(
                            child: Text(
                              'No sessions scheduled for today',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: sessions.map((session) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                            child: NeumorphicContainer(
                              padding: const EdgeInsets.all(AppDimensions.paddingM),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                      boxShadow: NeumorphicStyles.getInsetShadow(),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          session.startTime?.split(':')[0] ?? '--',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          session.startTime?.split(':')[1] ?? '--',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.spacingM),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          session.batchName ?? session.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${session.startTime ?? '--'} - ${session.endTime ?? '--'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        if (session.location != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                session.location!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.spacingM,
                                      vertical: AppDimensions.spacingS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getSessionStatusColor(session),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    ),
                                    child: Text(
                                      _getSessionStatus(session).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const NeumorphicContainer(
                      padding: EdgeInsets.all(AppDimensions.paddingL),
                      child: Center(child: LoadingSpinner()),
                    ),
                    error: (error, stack) => NeumorphicContainer(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: ErrorDisplay(
                        message: 'Failed to load sessions',
                        onRetry: () => ref.invalidate(coachTodaySessionsProvider(coachId)),
                      ),
                    ),
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
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.check_circle_outline,
                          label: 'Mark Attendance',
                          onTap: () {
                            // Switch to attendance tab - handled by parent dashboard
                            // This would need to be passed via callback or state management
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.calendar_today_outlined,
                          label: 'View Schedule',
                          onTap: () {
                            // Navigate to schedule screen - will be in More menu
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

  Color _getSessionStatusColor(Schedule session) {
    final now = DateTime.now();
    final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (sessionDate.isBefore(today)) {
      return AppColors.textSecondary; // Completed
    } else if (sessionDate.isAtSameMomentAs(today)) {
      // Check if session time has passed
      if (session.startTime != null) {
        final timeParts = session.startTime!.split(':');
        if (timeParts.length >= 2) {
          final sessionHour = int.tryParse(timeParts[0]) ?? 0;
          final sessionMinute = int.tryParse(timeParts[1]) ?? 0;
          final sessionDateTime = DateTime(now.year, now.month, now.day, sessionHour, sessionMinute);
          
          if (now.isAfter(sessionDateTime)) {
            return AppColors.success; // Ongoing
          }
        }
      }
      return AppColors.accent; // Upcoming
    } else {
      return AppColors.accent; // Upcoming
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  boxShadow: NeumorphicStyles.getInsetShadow(),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.iconPrimary,
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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
              color: AppColors.iconPrimary,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
