import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import 'coach_announcements_screen.dart';
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
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/standard_page_header.dart';

/// Coach More Screen - Navigation hub for additional features
class CoachMoreScreen extends ConsumerStatefulWidget {
  const CoachMoreScreen({super.key});

  @override
  ConsumerState<CoachMoreScreen> createState() => _CoachMoreScreenState();
}

class _CoachMoreScreenState extends ConsumerState<CoachMoreScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          StandardPageHeader(
            title: 'More',
            subtitle: ref.watch(activeOwnerProvider).maybeWhen(
              data: (owner) => owner?.academyName,
              orElse: () => null,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.getScreenPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information Section
                const _SectionTitle(title: 'Information'),
                const SizedBox(height: AppDimensions.spacingM),
                _MenuItem(
                  icon: Icons.campaign_outlined,
                  title: 'Announcements',
                  subtitle: 'View academy announcements',
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
                  icon: Icons.notifications_none_outlined,
                  title: 'Notifications',
                  subtitle: 'View your alerts and updates',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.monitor_weight_outlined,
                  title: 'BMI Tracking',
                  subtitle: 'Track student BMI records',
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
                  icon: Icons.payments_outlined,
                  title: 'Fees Management',
                  subtitle: 'Manage student fees',
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
                  subtitle: 'View sessions, holidays, and academy events',
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
                  subtitle: 'Upload and manage training videos',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CoachVideoManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.event_busy_outlined,
                  title: 'Requests',
                  subtitle: 'Submit and view leave requests',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LeaveRequestScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.assessment_outlined,
                  title: 'Reports',
                  subtitle: 'Generate attendance and performance reports',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CoachReportsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // App Section
                const _SectionTitle(title: 'App'),
                const SizedBox(height: AppDimensions.spacingM),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'App preferences and notifications',
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
                  isDestructive: true,
                  onTap: () => _showLogoutConfirmation(),
                ),

                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardBackgroundColor,
        title: Text(
          'Logout',
          style: TextStyle(color: context.textPrimaryColor),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: context.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondaryColor),
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
              style: TextStyle(color: context.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppDimensions.getSectionTitleSize(context),
        color: context.textSecondaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
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
                  ? context.errorColor.withValues(alpha: 0.1)
                  : context.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? context.errorColor
                  : context.iconPrimaryColor,
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
                        ? context.errorColor
                        : context.textPrimaryColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: context.textTertiaryColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}
