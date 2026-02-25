import 'package:flutter/material.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/standard_bottom_nav.dart';
import 'student_home_screen.dart';
import 'student_attendance_screen.dart';
import 'student_performance_screen.dart';
import 'student_more_screen.dart';

/// Student Dashboard with bottom navigation
/// Matches Owner Dashboard design pattern
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const StudentAttendanceScreen(),
    const StudentPerformanceScreen(),
    const StudentMoreScreen(),
  ];

  final List<StandardBottomNavItem> _navItems = [
    StandardBottomNavItem(icon: Icons.home, label: 'Home'),
    StandardBottomNavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    StandardBottomNavItem(icon: Icons.trending_up, label: 'Performance'),
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
