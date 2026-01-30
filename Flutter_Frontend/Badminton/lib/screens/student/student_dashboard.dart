import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import 'student_home_screen.dart';
import 'student_batches_screen.dart';
import 'student_attendance_screen.dart';
import 'student_performance_screen.dart';
import 'student_more_screen.dart';

/// Student Dashboard with bottom navigation
/// Matches Owner Dashboard design pattern
class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const StudentBatchesScreen(),
    const StudentAttendanceScreen(),
    const StudentPerformanceScreen(),
    const StudentMoreScreen(),
  ];

  final List<_BottomNavItem> _navItems = [
    _BottomNavItem(icon: Icons.home, label: 'Home'),
    _BottomNavItem(icon: Icons.groups_outlined, label: 'Batches'),
    _BottomNavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    _BottomNavItem(icon: Icons.trending_up, label: 'Performance'),
    _BottomNavItem(icon: Icons.more_horiz, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = isDark
        ? AppColors.surfaceLight
        : AppColorsLight.surfaceLight;
    final shadowColor = isDark
        ? AppColors.shadowDark
        : AppColorsLight.shadowDark;

    // Check student status - redirect if pending
    final authStateAsync = ref.watch(authProvider);
    
    return authStateAsync.when(
      loading: () => Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Error loading account',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (authState) {
        if (authState is! Authenticated || authState.userType != 'student') {
          // Not a student, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });
          return const SizedBox.shrink();
        }

        final userId = authState.userId;
        final studentAsync = ref.watch(studentByIdProvider(userId));

        return studentAsync.when(
          loading: () => Scaffold(
            backgroundColor: backgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading student data',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (student) {
            // If status is pending, redirect to pending approval screen
            if (student.status == 'pending') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/student-pending');
              });
              return const SizedBox.shrink();
            }

            // Status is active, show dashboard
            return _buildDashboard(context, theme, isDark, backgroundColor, surfaceColor, shadowColor);
          },
        );
      },
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color backgroundColor,
    Color surfaceColor,
    Color shadowColor,
  ) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradient
              : AppColorsLight.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Content Area
              Expanded(child: _screens[_currentIndex]),

              // Bottom Navigation
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border(
                    top: BorderSide(color: surfaceColor, width: 1),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.cardBackground
        : AppColorsLight.cardBackground;
    final activeColor = isDark
        ? AppColors.iconActive
        : AppColorsLight.iconActive;
    final inactiveColor = isDark
        ? AppColors.textTertiary
        : AppColorsLight.textTertiary;

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
          color: isActive ? cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isActive ? NeumorphicStyles.getPressedShadow() : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
