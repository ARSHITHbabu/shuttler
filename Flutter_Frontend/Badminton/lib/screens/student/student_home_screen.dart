import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/contact_utils.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import 'student_attendance_screen.dart';
import 'student_performance_screen.dart';
import 'student_bmi_screen.dart';
import 'student_fees_screen.dart';

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
                    context,
                    isDark,
                    dashboardData.attendanceRate,
                    dashboardData.performanceScore,
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Upcoming Practice Sessions
                  _buildUpcomingSessions(isDark, dashboardData.upcomingSessions),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Quick Actions
                  _buildQuickActions(context, isDark, userId),

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
    BuildContext context,
    bool isDark,
    double attendanceRate,
    double performanceScore,
  ) {

    return Padding(
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
            icon: Icons.check_circle_outline,
            value: '${attendanceRate.toStringAsFixed(0)}%',
            label: 'Attendance Rate',
            isDark: isDark,
            valueColor: _getAttendanceColor(attendanceRate, isDark),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _buildScreenWithBackground(
                    context,
                    const StudentAttendanceScreen(),
                  ),
                ),
              );
            },
          ),
          _StatCard(
            icon: Icons.trending_up,
            value: performanceScore > 0 ? '${performanceScore.toStringAsFixed(1)}/5' : 'N/A',
            label: 'Performance',
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _buildScreenWithBackground(
                    context,
                    const StudentPerformanceScreen(),
                  ),
                ),
              );
            },
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
            'Upcoming Practice Sessions',
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
                            'No upcoming practice sessions',
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

  Widget _buildQuickActions(BuildContext context, bool isDark, int studentId) {
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
                  icon: Icons.person_outline,
                  label: 'Contact Owner',
                  isDark: isDark,
                  onTap: () => _showContactDialog(context, isDark, 'Owner', studentId),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.sports_tennis_outlined,
                  label: 'Contact Coach',
                  isDark: isDark,
                  onTap: () => _showContactDialog(context, isDark, 'Coach', studentId),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.monitor_weight_outlined,
                  label: 'BMI',
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _buildScreenWithBackground(
                          context,
                          const StudentBMIScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Fees',
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _buildScreenWithBackground(
                          context,
                          const StudentFeesScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScreenWithBackground(BuildContext context, Widget screen) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Wrap the screen in a Scaffold with gradient background
    // The screen's Scaffold has transparent background, so the gradient will show through
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.backgroundGradient : AppColorsLight.backgroundGradient,
        ),
        child: screen,
      ),
    );
  }

  void _showContactDialog(BuildContext context, bool isDark, String contactType, int studentId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
        title: Text(
          'Contact $contactType',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (context, ref, child) {
              if (contactType == 'Owner') {
                final ownerAsync = ref.watch(activeOwnerProvider);
                return ownerAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading owner details: $err', style: TextStyle(color: isDark ? AppColors.error : AppColorsLight.error)),
                  data: (owner) {
                    if (owner == null) {
                      return Text('No owner details found.', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary));
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContactDetailRow(Icons.person, owner.name, isDark),
                        const SizedBox(height: 12),
                        _buildContactDetailRow(
                          Icons.phone, 
                          owner.phone, 
                          isDark,
                          onTap: () => ContactUtils.showContactOptions(context, owner.phone, name: owner.name),
                        ),
                        const SizedBox(height: 12),
                        _buildContactDetailRow(
                          Icons.email, 
                          owner.email, 
                          isDark,
                          onTap: () => ContactUtils.launchEmail(owner.email),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Coach
                final coachesAsync = ref.watch(studentCoachesProvider(studentId));
                return coachesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading coach details: $err', style: TextStyle(color: isDark ? AppColors.error : AppColorsLight.error)),
                  data: (coaches) {
                    if (coaches.isEmpty) {
                      return Text('No coaches assigned yet.', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary));
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: coaches.length,
                      separatorBuilder: (context, index) => Divider(color: isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight),
                      itemBuilder: (context, index) {
                        final coach = coaches[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coach.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildContactDetailRow(
                              Icons.phone, 
                              coach.phone, 
                              isDark,
                              onTap: () => ContactUtils.showContactOptions(context, coach.phone, name: coach.name),
                            ),
                            const SizedBox(height: 8),
                            _buildContactDetailRow(
                              Icons.email, 
                              coach.email, 
                              isDark,
                              onTap: () => ContactUtils.launchEmail(coach.email),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailRow(IconData icon, String value, bool isDark, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.accent : AppColorsLight.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: (isDark ? AppColors.accent : AppColorsLight.accent).withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
          ),
          if (onTap != null)
            Icon(
              Icons.open_in_new,
              size: 14,
              color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
            ),
        ],
      ),
    );
  }

  // Local launch methods removed - using ContactUtils


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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: AppDimensions.spacingS),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
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
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
