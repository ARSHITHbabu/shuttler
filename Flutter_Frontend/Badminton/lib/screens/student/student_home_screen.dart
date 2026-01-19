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

/// Student Home Screen - Dashboard overview
/// READ-ONLY view of student's personal statistics and upcoming sessions
class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  // Removed manual state management - using providers instead

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get user ID from auth provider
    final authStateAsync = ref.watch(authProvider);
    
    return authStateAsync.when(
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: DashboardSkeleton()),
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
              message: 'Please log in to view dashboard',
              onRetry: () => ref.invalidate(authProvider),
            ),
          );
        }

        final userId = authState.userId;
        final dashboardAsync = ref.watch(studentDashboardProvider(userId));

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(studentDashboardProvider(userId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: dashboardAsync.when(
              loading: () => const DashboardSkeleton(),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load dashboard: ${error.toString()}',
                onRetry: () => ref.invalidate(studentDashboardProvider(userId)),
              ),
              data: (dashboardData) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(isDark, dashboardData.studentName),

                  // Stats Grid
                  _buildStatsGrid(
                    isDark,
                    dashboardData.attendanceRate,
                    dashboardData.performanceScore,
                    dashboardData.bmiStatus,
                    dashboardData.feeStatus,
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Today's Insights
                  _buildTodaysInsights(isDark, dashboardData.attendanceRate),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Upcoming Sessions
                  _buildUpcomingSessions(isDark, dashboardData.upcomingSessions),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Quick Actions
                  _buildQuickActions(isDark),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, String studentName) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            studentName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getFormattedDate(),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    bool isDark,
    double attendanceRate,
    double performanceScore,
    String bmiStatus,
    String feeStatus,
  ) {

    return Padding(
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
            icon: Icons.check_circle_outline,
            value: '${attendanceRate.toStringAsFixed(0)}%',
            label: 'Attendance Rate',
            isDark: isDark,
            valueColor: _getAttendanceColor(attendanceRate, isDark),
          ),
          _StatCard(
            icon: Icons.trending_up,
            value: performanceScore > 0 ? '${performanceScore.toStringAsFixed(1)}/5' : 'N/A',
            label: 'Performance',
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.monitor_weight_outlined,
            value: bmiStatus,
            label: 'BMI Status',
            isDark: isDark,
            valueColor: _getBmiStatusColor(bmiStatus, isDark),
          ),
          _StatCard(
            icon: Icons.account_balance_wallet_outlined,
            value: feeStatus,
            label: 'Fee Status',
            isDark: isDark,
            valueColor: _getFeeStatusColor(feeStatus, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysInsights(bool isDark, double attendanceRate) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.background : AppColorsLight.background,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        boxShadow: NeumorphicStyles.getInsetShadow(),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        size: 20,
                        color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Attendance',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                            ),
                          ),
                          Text(
                            '${attendanceRate.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.background : AppColorsLight.background,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: NeumorphicStyles.getSmallInsetShadow(),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (attendanceRate / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getAttendanceColor(attendanceRate, isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessions(bool isDark, List<Map<String, dynamic>> upcomingSessions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Sessions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: upcomingSessions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingM),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          Text(
                            'No upcoming sessions',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: upcomingSessions.asMap().entries.map((entry) {
                      final session = entry.value;
                      final isLast = entry.key == upcomingSessions.length - 1;
                      return Column(
                        children: [
                          _UpcomingSessionItem(
                            batchName: session['batch_name'] ?? 'Unknown Batch',
                            time: session['time'] ?? '',
                            location: session['location'] ?? '',
                            isDark: isDark,
                          ),
                          if (!isLast)
                            Divider(
                              color: isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight,
                              height: AppDimensions.spacingL,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.check_circle_outline,
                  label: 'View Attendance',
                  isDark: isDark,
                  onTap: () {
                    // Navigate to attendance tab (index 1)
                    // This will be handled by parent dashboard
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.trending_up,
                  label: 'View Performance',
                  isDark: isDark,
                  onTap: () {
                    // Navigate to performance tab (index 2)
                    // This will be handled by parent dashboard
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Removed _calculateStats - now handled by studentDashboardProvider

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Color _getAttendanceColor(double rate, bool isDark) {
    if (rate >= 80) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (rate >= 60) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }

  Color _getBmiStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'healthy':
        return isDark ? AppColors.success : AppColorsLight.success;
      case 'underweight':
      case 'overweight':
        return Colors.orange;
      case 'obese':
        return isDark ? AppColors.error : AppColorsLight.error;
      default:
        return isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    }
  }

  Color _getFeeStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'clear':
        return isDark ? AppColors.success : AppColorsLight.success;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return isDark ? AppColors.error : AppColorsLight.error;
      default:
        return isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColorsLight.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              boxShadow: NeumorphicStyles.getInsetShadow(),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSessionItem extends StatelessWidget {
  final String batchName;
  final String time;
  final String location;
  final bool isDark;

  const _UpcomingSessionItem({
    required this.batchName,
    required this.time,
    required this.location,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.background : AppColorsLight.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: NeumorphicStyles.getInsetShadow(),
          ),
          child: Icon(
            Icons.sports_tennis,
            size: 20,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
              ),
              if (location.isNotEmpty)
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
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
              color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
