import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import 'session_management_screen.dart';
import 'announcement_management_screen.dart';
import 'calendar_view_screen.dart';
import 'reports_screen.dart';
import 'bmi_tracking_screen.dart';
import 'performance_tracking_screen.dart';
import 'fees_screen.dart';
import 'settings_screen.dart';

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
            const Text(
              'More',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Account Section
            _SectionTitle(title: 'Account'),
            const SizedBox(height: AppDimensions.spacingM),
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                setState(() {
                  _currentView = 'profile';
                });
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.business_outlined,
              title: 'Academy Details',
              onTap: () {
                setState(() {
                  _currentView = 'academy';
                });
              },
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Management Section
            _SectionTitle(title: 'Management'),
            const SizedBox(height: AppDimensions.spacingM),
            _MenuItem(
              icon: Icons.access_time_outlined,
              title: 'Sessions',
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
              icon: Icons.campaign_outlined,
              title: 'Announcements',
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
              icon: Icons.calendar_today_outlined,
              title: 'Calendar',
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
              icon: Icons.description_outlined,
              title: 'Reports',
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
              icon: Icons.monitor_weight_outlined,
              title: 'BMI Tracking',
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
              icon: Icons.trending_up_outlined,
              title: 'Performance Tracking',
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
              icon: Icons.payments_outlined,
              title: 'Fee Management',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FeesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // App Section
            _SectionTitle(title: 'App'),
            const SizedBox(height: AppDimensions.spacingM),
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
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
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (mounted) {
                  context.go('/');
                }
              },
              isDestructive: true,
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
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
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
          Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.iconPrimary,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
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
                      boxShadow: NeumorphicStyles.getInsetShadow(),
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
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicInsetContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: const TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicInsetContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: const TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicInsetContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: const TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Phone',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              onTap: () {
                // Save changes
              },
              child: const Center(
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
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
            NeumorphicInsetContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: const TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Academy Name',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicInsetContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: const TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Address',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              onTap: () {
                // Save changes
              },
              child: const Center(
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
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
