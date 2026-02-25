import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import 'student_fees_screen.dart';
import 'student_bmi_screen.dart';
import 'student_announcements_screen.dart';
import 'student_schedule_screen.dart';
import 'student_profile_screen.dart';
import 'student_settings_screen.dart';
import 'student_batches_screen.dart';
import 'student_videos_screen.dart';
import '../common/academy_info_screen.dart';
import '../owner/notifications_screen.dart';
import '../../providers/owner_provider.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/standard_page_header.dart';

/// Student More Screen - Navigation hub for additional features
/// All features are READ-ONLY for students
class StudentMoreScreen extends ConsumerStatefulWidget {
  const StudentMoreScreen({super.key});

  @override
  ConsumerState<StudentMoreScreen> createState() => _StudentMoreScreenState();
}

class _StudentMoreScreenState extends ConsumerState<StudentMoreScreen> {
  String? _currentView;

  @override
  Widget build(BuildContext context) {
    if (_currentView != null) {
      return _buildSubScreen();
    }

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
                // Information Section (READ-ONLY)
                const _SectionTitle(title: 'Information'),
                const SizedBox(height: AppDimensions.spacingM),
                _MenuItem(
                  icon: Icons.campaign_outlined,
                  title: 'Announcements',
                  subtitle: 'View academy announcements',
                  onTap: () => setState(() => _currentView = 'announcements'),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notifications',
                  subtitle: 'View your alerts and updates',
                  onTap: () => setState(() => _currentView = 'notifications'),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.business_outlined,
                  title: 'Academy Details',
                  subtitle: 'View academy and owner information',
                  onTap: () => setState(() => _currentView = 'academy'),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.monitor_weight_outlined,
                  title: 'BMI Tracker',
                  subtitle: 'View your BMI history and health tips',
                  onTap: () => setState(() => _currentView = 'bmi'),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.payments_outlined,
                  title: 'Fee Status',
                  subtitle: 'View your fee records and payment history',
                  onTap: () => setState(() => _currentView = 'fees'),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Schedule',
                  subtitle: 'View your session schedule',
                  onTap: () => setState(() => _currentView = 'schedule'),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.group_outlined,
                  title: 'Batches',
                  subtitle: 'View your enrolled batches',
                  onTap: () => setState(() => _currentView = 'batches'),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _MenuItem(
                  icon: Icons.video_library_outlined,
                  title: 'Training Videos',
                  subtitle: 'View videos uploaded by your coach',
                  onTap: () => setState(() => _currentView = 'videos'),
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // App Section
                const _SectionTitle(title: 'App'),
                const SizedBox(height: AppDimensions.spacingM),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'App preferences and notifications',
                  onTap: () => setState(() => _currentView = 'settings'),
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

  Widget _buildSubScreen() {
    switch (_currentView) {
      case 'profile':
        return StudentProfileScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'fees':
        return StudentFeesScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'bmi':
        return StudentBMIScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'announcements':
        return StudentAnnouncementsScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'notifications':
        return NotificationsScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'academy':
        return AcademyInfoScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'schedule':
      case 'calendar':
        return StudentScheduleScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'videos':
        return StudentVideosScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'settings':
        return StudentSettingsScreen(
          onBack: () => setState(() => _currentView = null),
        );
      case 'batches':
        return StudentBatchesScreen(
          onBack: () => setState(() => _currentView = null),
        );
      default:
        return const SizedBox();
    }
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
