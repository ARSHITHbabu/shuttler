import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import 'coach_announcements_screen.dart';
import 'coach_attendance_view_screen.dart';
import 'coach_schedule_screen.dart';
import 'coach_calendar_screen.dart';
import 'coach_settings_screen.dart';
import 'coach_video_management_screen.dart';
import '../owner/bmi_tracking_screen.dart';
import '../owner/performance_tracking_screen.dart';
import 'coach_fees_screen.dart';

/// Coach More Screen - Navigation hub for additional features
class CoachMoreScreen extends ConsumerStatefulWidget {
  const CoachMoreScreen({super.key});

  @override
  ConsumerState<CoachMoreScreen> createState() => _CoachMoreScreenState();
}

class _CoachMoreScreenState extends ConsumerState<CoachMoreScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'More',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Information Section
            _SectionTitle(title: 'Information', isDark: isDark),
            const SizedBox(height: AppDimensions.spacingM),
            _MenuItem(
              icon: Icons.campaign_outlined,
              title: 'Announcements',
              subtitle: 'View academy announcements',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CoachAnnouncementsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.fact_check_outlined,
              title: 'Attendance Rate',
              subtitle: 'View attendance statistics',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CoachAttendanceViewScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.monitor_weight_outlined,
              title: 'BMI Tracking',
              subtitle: 'Track student BMI records',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BMITrackingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.calendar_month_outlined,
              title: 'Calendar',
              subtitle: 'View academy calendar events',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CoachCalendarScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.payments_outlined,
              title: 'Fees Management',
              subtitle: 'Manage student fees',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CoachFeesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.trending_up_outlined,
              title: 'Performance Tracking',
              subtitle: 'Track student performance',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PerformanceTrackingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.calendar_today_outlined,
              title: 'Schedule',
              subtitle: 'View your session schedule',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CoachScheduleScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.video_library_outlined,
              title: 'Video Management',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CoachVideoManagementScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // App Section
            _SectionTitle(title: 'App', isDark: isDark),
            const SizedBox(height: AppDimensions.spacingM),
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'App preferences and notifications',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CoachSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              isDark: isDark,
              isDestructive: true,
              onTap: () => _showLogoutConfirmation(isDark),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final router = GoRouter.of(context);
              navigator.pop();
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                router.go('/');
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: isDark ? AppColors.error : AppColorsLight.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive
                  ? (isDark ? AppColors.error : AppColorsLight.error).withValues(alpha: 0.1)
                  : (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? (isDark ? AppColors.error : AppColorsLight.error)
                  : (isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary),
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? (isDark ? AppColors.error : AppColorsLight.error)
                        : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
