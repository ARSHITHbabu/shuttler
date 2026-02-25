import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import 'session_management_screen.dart';
import 'session_season_management_screen.dart';
import 'announcement_management_screen.dart';
import 'calendar_view_screen.dart';
import 'reports_screen.dart';
import 'bmi_tracking_screen.dart';
import 'performance_tracking_screen.dart';
import 'video_management_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'requests_screen.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/standard_page_header.dart';

/// More Screen - Settings and additional features
/// Matches React reference: MoreScreen.tsx
class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  String? _currentView; // 'profile', 'academy', 'sessions', 'announcements', 'calendar', 'settings'

  @override
  Widget build(BuildContext context) {
    final padding = AppDimensions.getScreenPadding(context);

    if (_currentView != null) {
      return _buildSubScreen();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Standardized Header
          const StandardPageHeader(title: 'More'),

          const SizedBox(height: AppDimensions.spacingM),

          // Information Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: const _SectionTitle(title: 'Information'),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _MenuItem(
            padding: padding,
            icon: Icons.campaign_outlined,
            title: 'Announcements',
            subtitle: 'Manage academy announcements',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AnnouncementManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _MenuItem(
            padding: padding,
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
            padding: padding,
            icon: Icons.calendar_today_outlined,
            title: 'Calendar',
            subtitle: 'View academy calendar events',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CalendarViewScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _MenuItem(
            padding: padding,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'View and manage notifications',
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
            padding: padding,
            icon: Icons.trending_up_outlined,
            title: 'Performance Tracking',
            subtitle: 'Track student performance metrics',
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
            padding: padding,
            icon: Icons.video_library_outlined,
            title: 'Videos',
            subtitle: 'Manage training videos',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VideoManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _MenuItem(
            padding: padding,
            icon: Icons.access_time_outlined,
            title: 'Practice Sessions',
            subtitle: 'Manage practice, tournaments, and camps',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SessionManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _MenuItem(
            padding: padding,
            icon: Icons.description_outlined,
            title: 'Reports',
            subtitle: 'View academy reports and analytics',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReportsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _MenuItem(
            padding: padding,
            icon: Icons.event_note_outlined,
            title: 'Season Management',
            subtitle: 'Manage academy seasons',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SessionSeasonManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _MenuItem(
            padding: padding,
            icon: Icons.assignment_outlined,
            title: 'Requests',
            subtitle: 'View and approve leave requests',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RequestsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // App Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: const _SectionTitle(title: 'App'),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _MenuItem(
            padding: padding,
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences and notifications',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _MenuItem(
            padding: padding,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            onTap: () => _showLogoutConfirmation(),
          ),

          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildSubScreen() {
    switch (_currentView) {
      case 'profile':
        return _ProfileView(
          onBack: () {
            setState(() {
              _currentView = null;
            });
          },
        );
      case 'academy':
        return _AcademyView(
          onBack: () {
            setState(() {
              _currentView = null;
            });
          },
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
          style: TextStyle(
            color: context.textPrimaryColor,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: context.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.textSecondaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final router = GoRouter.of(context);
              Navigator.of(dialogContext).pop();
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                router.go('/');
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: context.errorColor,
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

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
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
  final double padding;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.padding,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, AppDimensions.spacingS),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? context.errorColor.withOpacity(0.1)
                    : context.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                icon,
                color: isDestructive ? context.errorColor : context.accentColor,
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
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final VoidCallback onBack;

  const _ProfileView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: onBack,
              child: Text(
                '← Back',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 32,
                          color: context.iconPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    'Admin Owner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  Text(
                    'Owner',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _AcademyView extends StatelessWidget {
  final VoidCallback onBack;

  const _AcademyView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: onBack,
              child: Text(
                '← Back',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Academy Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Center(
              child: Text(
                'Navigate to Academy Details from Settings',
                style: TextStyle(
                  fontSize: 16,
                  color: context.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _PlaceholderView({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: onBack,
              child: Text(
                '← Back',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Center(
              child: Text(
                'Coming in Phase 4',
                style: TextStyle(
                  fontSize: 16,
                  color: context.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
