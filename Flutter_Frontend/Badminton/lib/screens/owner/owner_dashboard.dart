import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import 'home_screen.dart';
import 'batches_screen.dart';
import 'attendance_screen.dart';
import 'more_screen.dart';

/// Owner Dashboard with bottom navigation
/// Matches React reference: OwnerDashboard.tsx
class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BatchesScreen(),
    const AttendanceScreen(),
    const MoreScreen(),
  ];

  final List<_BottomNavItem> _navItems = [
    _BottomNavItem(icon: Icons.home, label: 'Home'),
    _BottomNavItem(icon: Icons.groups, label: 'Batches'),
    _BottomNavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    _BottomNavItem(icon: Icons.more_horiz, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Content Area
              Expanded(
                child: _screens[_currentIndex],
              ),
              
              // Bottom Navigation
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.surfaceLight,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowDark.withOpacity(0.5),
                      offset: const Offset(0, -4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingS,
                      vertical: AppDimensions.spacingM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        _navItems.length,
                        (index) => _buildNavItem(index),
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

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isActive ? NeumorphicStyles.getPressedShadow() : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isActive ? AppColors.iconActive : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.iconActive : AppColors.textTertiary,
              ),
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
