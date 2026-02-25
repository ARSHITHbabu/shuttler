import 'package:flutter/material.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/standard_bottom_nav.dart';
import 'coach_home_screen.dart';
import 'coach_batches_screen.dart';
import 'coach_attendance_screen.dart';
import 'coach_more_screen.dart';

/// Coach Dashboard with bottom navigation
/// Matches Owner Dashboard pattern
class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CoachHomeScreen(),
    const CoachBatchesScreen(),
    const CoachAttendanceScreen(),
    const CoachMoreScreen(),
  ];

  final List<StandardBottomNavItem> _navItems = [
    StandardBottomNavItem(icon: Icons.home, label: 'Home'),
    StandardBottomNavItem(icon: Icons.groups, label: 'Batches'),
    StandardBottomNavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    StandardBottomNavItem(icon: Icons.more_horiz, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
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
                child: _screens[_currentIndex],
              ),

              // Standardized Bottom Navigation
              StandardBottomNav(
                currentIndex: _currentIndex,
                items: _navItems,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
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
