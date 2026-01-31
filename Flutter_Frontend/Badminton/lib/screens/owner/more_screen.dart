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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentView != null) {
      return _buildSubScreen();
    }

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
              subtitle: 'Manage academy announcements',
              isDark: isDark,
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
              icon: Icons.calendar_today_outlined,
              title: 'Calendar',
              subtitle: 'View academy calendar events',
              isDark: isDark,
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
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'View and manage notifications',
              isDark: isDark,
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
              icon: Icons.trending_up_outlined,
              title: 'Performance Tracking',
              subtitle: 'Track student performance metrics',
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
              icon: Icons.video_library_outlined,
              title: 'Videos',
              subtitle: 'Manage training videos',
              isDark: isDark,
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
              icon: Icons.access_time_outlined,
              title: 'Practice Sessions',
              subtitle: 'Manage practice sessions',
              isDark: isDark,
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
              icon: Icons.description_outlined,
              title: 'Reports',
              subtitle: 'View academy reports and analytics',
              isDark: isDark,
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
              icon: Icons.event_note_outlined,
              title: 'Season Management',
              subtitle: 'Manage seasons and sessions',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SessionSeasonManagementScreen(),
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
                    builder: (context) => const SettingsScreen(),
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
      // These are now handled via navigation, but keeping for backward compatibility
      case 'sessions':
      case 'announcements':
      case 'calendar':
      case 'settings':
        return _PlaceholderView(
          title: _currentView!.replaceFirst(_currentView![0], _currentView![0].toUpperCase()),
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
              child: const Text(
                '← Back',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 32,
                          color: AppColors.iconPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  const Text(
                    'Admin Owner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Owner',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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
              child: const Text(
                '← Back',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Text(
              'Academy Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            const Center(
              child: Text(
                'Navigate to Academy Details from Settings',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
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
              child: const Text(
                '← Back',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            const Center(
              child: Text(
                'Coming in Phase 4',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
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
