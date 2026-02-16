import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import 'coach_announcements_screen.dart';
import 'coach_attendance_screen.dart';
import 'coach_schedule_screen.dart';
import 'coach_settings_screen.dart';
import 'coach_video_management_screen.dart';
import '../owner/bmi_tracking_screen.dart';
import '../owner/performance_tracking_screen.dart';
import 'coach_fees_screen.dart';
import 'leave_request_screen.dart';
import 'coach_reports_screen.dart';
import '../owner/notifications_screen.dart';
import '../../providers/owner_provider.dart';

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
            ref.watch(activeOwnerProvider).when(
                  data: (owner) => owner?.academyName != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            owner!.academyName!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.accent : AppColorsLight.accent,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
            const SizedBox(height: AppDimensions.spacingL),

            // Information Section
            _SectionTitle(title: 'Academy Hub', isDark: isDark),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.campaign_outlined,
                    title: 'Announcements',
                    subtitle: 'View academy updates',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const CoachAnnouncementsScreen()),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications',
                    subtitle: 'View your alerts',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const NotificationsScreen()),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Schedule',
                    subtitle: 'Academy sessions and events',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const CoachScheduleScreen()),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacingL),

            // Management Section
            _SectionTitle(title: 'Player Management', isDark: isDark),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.monitor_weight_outlined,
                    title: 'BMI Records',
                    subtitle: 'Track player health',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const BMITrackingScreen()),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuItem(
                    icon: Icons.trending_up_outlined,
                    title: 'Performance',
                    subtitle: 'Player growth tracking',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const PerformanceTrackingScreen()),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuItem(
                    icon: Icons.payments_outlined,
                    title: 'Fees Status',
                    subtitle: 'Monitor player payments',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const CoachFeesScreen()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Tools Section
            _SectionTitle(title: 'Tools & Reports', isDark: isDark),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.video_library_outlined,
                    title: 'Video Vault',
                    subtitle: 'Manage training videos',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const CoachVideoManagementScreen()),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuItem(
                    icon: Icons.assessment_outlined,
                    title: 'Analytics Reports',
                    subtitle: 'Generate detailed stats',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const CoachReportsScreen()),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuItem(
                    icon: Icons.event_busy_outlined,
                    title: 'Leave Requests',
                    subtitle: 'Self attendance management',
                    isDark: isDark,
                    onTap: () => _navigateTo(context, const LeaveRequestScreen()),
                  ),
                ],
              ),
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

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
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
