import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/owner_navigation_provider.dart';
import '../../widgets/common/standard_bottom_nav.dart';
import '../../widgets/owner/force_change_password_dialog.dart';
import 'home_screen.dart';
import 'batches_screen.dart';
import 'attendance_screen.dart';
import 'fees_screen.dart';
import 'more_screen.dart';
import '../../core/utils/theme_colors.dart';

/// Owner Dashboard with bottom navigation
/// Matches React reference: OwnerDashboard.tsx
class OwnerDashboard extends ConsumerStatefulWidget {
  const OwnerDashboard({super.key});

  @override
  ConsumerState<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends ConsumerState<OwnerDashboard> {
  // Navigation state is now managed by ownerBottomNavIndexProvider

  @override
  void initState() {
    super.initState();
    // Check if user must change password
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForceChangePassword();
    });
  }

  void _checkForceChangePassword() {
    final authState = ref.read(authProvider).value;
    if (authState is Authenticated && authState.mustChangePassword) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ForceChangePasswordDialog(),
      );
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const BatchesScreen(),
    const AttendanceScreen(),
    const FeesScreen(),
    const MoreScreen(),
  ];

  final List<StandardBottomNavItem> _navItems = [
    StandardBottomNavItem(icon: Icons.home, label: 'Home'),
    StandardBottomNavItem(icon: Icons.groups, label: 'Batches'),
    StandardBottomNavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    StandardBottomNavItem(icon: Icons.payments_outlined, label: 'Fees'),
    StandardBottomNavItem(icon: Icons.more_horiz, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(ownerBottomNavIndexProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: context.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Content Area
              Expanded(
                child: RepaintBoundary(
                  child: _screens[currentIndex],
                ),
              ),

              // Standardized Bottom Navigation
              StandardBottomNav(
                currentIndex: currentIndex,
                items: _navItems,
                onTap: (index) {
                  ref.read(ownerBottomNavIndexProvider.notifier).state = index;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;

  _BottomNavItem({required this.icon, required this.label});
}
