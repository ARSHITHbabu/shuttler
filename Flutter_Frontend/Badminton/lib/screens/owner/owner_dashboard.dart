import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/owner_navigation_provider.dart';
import '../../widgets/owner/force_change_password_dialog.dart';
import 'home_screen.dart';
import 'batches_screen.dart';
import 'attendance_screen.dart';
import 'fees_screen.dart';
import 'more_screen.dart';

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

  final List<_BottomNavItem> _navItems = [
    _BottomNavItem(icon: Icons.home, label: 'Home'),
    _BottomNavItem(icon: Icons.groups, label: 'Batches'),
    _BottomNavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    _BottomNavItem(icon: Icons.payments_outlined, label: 'Fees'),
    _BottomNavItem(icon: Icons.more_horiz, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final currentIndex = ref.watch(ownerBottomNavIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight;
    final shadowColor = isDark ? AppColors.shadowDark : AppColorsLight.shadowDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.backgroundGradient : AppColorsLight.backgroundGradient,
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

              // Bottom Navigation
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: surfaceColor,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.5),
                      offset: const Offset(0, -4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 4 : AppDimensions.spacingS,
                      vertical: isSmallScreen ? 8 : AppDimensions.spacingM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        _navItems.length,
                        (index) => _buildNavItem(index, currentIndex, isSmallScreen),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, int currentIndex, bool isSmallScreen) {
    final item = _navItems[index];
    final isActive = currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;
    final activeColor = isDark ? AppColors.iconActive : AppColorsLight.iconActive;
    final inactiveColor = isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;

    return GestureDetector(
      onTap: () {
        ref.read(ownerBottomNavIndexProvider.notifier).state = index;
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? AppDimensions.paddingS : AppDimensions.paddingM,
          vertical: isSmallScreen ? 6 : AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isActive ? cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isActive ? NeumorphicStyles.getPressedShadow() : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? activeColor : inactiveColor,
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

class _BottomNavItem {
  final IconData icon;
  final String label;

  _BottomNavItem({required this.icon, required this.label});
}
