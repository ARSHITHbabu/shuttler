# Coach Portal - Complete Implementation Guide
## All Screens with Uniform Design from Owner Portal

> **Complete implementation from login to settings**
> **Following exact neumorphic design system from owner portal**
> **All screens with database integration and API calls**

---

## Table of Contents
1. [Design System Reference](#design-system-reference)
2. [Screen Architecture](#screen-architecture)
3. [Screen Implementations](#screen-implementations)
   - [1. Login Screen](#1-login-screen)
   - [2. Coach Dashboard (Container)](#2-coach-dashboard-container)
   - [3. Coach Home Screen](#3-coach-home-screen)
   - [4. Coach Batches Screen](#4-coach-batches-screen)
   - [5. Coach Attendance Screen](#5-coach-attendance-screen)
   - [6. Coach Announcements Screen](#6-coach-announcements-screen)
   - [7. Coach Schedule Screen](#7-coach-schedule-screen)
   - [8. Coach Profile Screen](#8-coach-profile-screen)
   - [9. Coach Settings Screen](#9-coach-settings-screen)
4. [Common Components](#common-components)
5. [Navigation & Routing](#navigation--routing)
6. [API Integration](#api-integration)
7. [State Management](#state-management)
8. [Implementation Checklist](#implementation-checklist)

---

## Design System Reference

### Colors (AppColors)
```dart
// From: lib/core/constants/colors.dart
class AppColors {
  // Dark Mode Colors (Primary)
  static const Color background = Color(0xFF2C2C2E);
  static const Color cardBackground = Color(0xFF3A3A3C);
  static const Color accent = Color(0xFF0A84FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF98989F);
  static const Color textTertiary = Color(0xFF636366);
  static const Color textHint = Color(0xFF48484A);

  // Icon Colors
  static const Color iconPrimary = Color(0xFF8E8E93);
  static const Color iconActive = Color(0xFF0A84FF);

  // Status Colors
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFFD60A);

  // Shadow Colors
  static const Color shadowDark = Color(0xFF000000);
  static const Color shadowLight = Color(0xFF505050);
  static const Color surfaceLight = Color(0xFF48484A);

  // Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
  );
}

// Light Mode Colors
class AppColorsLight {
  static const Color background = Color(0xFFF2F2F7);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF007AFF);

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textTertiary = Color(0xFF8E8E93);

  static const Color iconPrimary = Color(0xFF8E8E93);
  static const Color iconActive = Color(0xFF007AFF);

  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);

  static const Color shadowDark = Color(0xFFD1D1D6);
  static const Color shadowLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFE5E5EA);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2F2F7), Color(0xFFE5E5EA)],
  );
}
```

### Dimensions (AppDimensions)
```dart
// From: lib/core/constants/dimensions.dart
class AppDimensions {
  // Padding
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXl = 20.0;
  static const double paddingXxl = 24.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 20.0;
}
```

### Neumorphic Styles
```dart
// From: lib/core/theme/neumorphic_styles.dart
class NeumorphicStyles {
  static List<BoxShadow> getElevatedShadow() {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withValues(alpha: 0.5),
        offset: const Offset(4, 4),
        blurRadius: 8,
      ),
      BoxShadow(
        color: AppColors.shadowLight.withValues(alpha: 0.05),
        offset: const Offset(-4, -4),
        blurRadius: 8,
      ),
    ];
  }

  static List<BoxShadow> getInsetShadow() {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withValues(alpha: 0.3),
        offset: const Offset(2, 2),
        blurRadius: 4,
        inset: true,
      ),
      BoxShadow(
        color: AppColors.shadowLight.withValues(alpha: 0.03),
        offset: const Offset(-2, -2),
        blurRadius: 4,
        inset: true,
      ),
    ];
  }

  static List<BoxShadow> getPressedShadow() {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withValues(alpha: 0.4),
        offset: const Offset(1, 1),
        blurRadius: 3,
      ),
    ];
  }

  static List<BoxShadow> getSmallInsetShadow() {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withValues(alpha: 0.2),
        offset: const Offset(1, 1),
        blurRadius: 2,
        inset: true,
      ),
    ];
  }
}
```

### Typography
```dart
// Font Family: Poppins (from pubspec.yaml)
// Usage:
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
)
```

---

## Screen Architecture

### Navigation Structure
```
Coach Portal
├── Login Screen (Separate, not in dashboard)
└── Coach Dashboard (Bottom Navigation Container)
    ├── Home (Index 0)
    ├── Batches (Index 1)
    ├── Attendance (Index 2)
    └── More (Index 3)
        ├── Announcements
        ├── Schedule
        ├── Profile
        └── Settings (with Logout)
```

### File Structure
```
lib/screens/coach/
├── coach_dashboard.dart              # Bottom nav container
├── coach_home_screen.dart            # Dashboard overview
├── coach_batches_screen.dart         # View assigned batches
├── coach_attendance_screen.dart      # Mark attendance
├── coach_announcements_screen.dart   # View announcements
├── coach_schedule_screen.dart        # View sessions
├── coach_profile_screen.dart         # Edit profile
├── coach_settings_screen.dart        # App settings
└── coach_more_screen.dart            # More menu
```

---

## Screen Implementations

### 1. Login Screen

**Path**: `lib/screens/auth/login_screen.dart`

**Note**: Login screen already exists and handles coach login with `userType: 'coach'`. It routes to `/coach-dashboard` after successful authentication.

**Key Features**:
- Role-based icon (Icons.person_outline for coach)
- Email & password validation
- Remember me checkbox
- Forgot password link
- Sign up link
- Loading state
- Error handling

**Already Implemented**: ✓ This screen already exists and supports coach login

---

### 2. Coach Dashboard (Container)

**Path**: `lib/screens/coach/coach_dashboard.dart`

**Purpose**: Main container with bottom navigation (mirrors owner_dashboard.dart)

**Code**:
```dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import 'coach_home_screen.dart';
import 'coach_batches_screen.dart';
import 'coach_attendance_screen.dart';
import 'coach_more_screen.dart';

/// Coach Dashboard with bottom navigation
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

  final List<_BottomNavItem> _navItems = [
    _BottomNavItem(icon: Icons.home, label: 'Home'),
    _BottomNavItem(icon: Icons.groups, label: 'Batches'),
    _BottomNavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    _BottomNavItem(icon: Icons.more_horiz, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
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
                child: _screens[_currentIndex],
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
    final cardColor = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;
    final activeColor = isDark ? AppColors.iconActive : AppColorsLight.iconActive;
    final inactiveColor = isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;

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
```

**Key Features**:
- Bottom navigation with 4 tabs
- Neumorphic design
- Active/inactive states
- Theme support (dark/light)
- Gradient background

**Estimated LOC**: ~150 lines

---

### 3. Coach Home Screen

**Path**: `lib/screens/coach/coach_home_screen.dart`

**Purpose**: Dashboard overview showing coach's assigned batches, today's sessions, and quick stats

**Database Tables Used**:
- `coaches` (coach details)
- `batches` (assigned batches)
- `batch_enrollments` (student count)
- `schedules` (today's sessions)
- `attendance` (attendance stats)

**API Endpoints**:
- `GET /api/coaches/{coach_id}` - Get coach details
- `GET /api/coaches/{coach_id}/batches` - Get assigned batches
- `GET /api/coaches/{coach_id}/stats` - Get coach statistics
- `GET /api/schedules/coach/{coach_id}/today` - Get today's sessions

**Code**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';

/// Coach Home Screen - Dashboard overview
class CoachHomeScreen extends ConsumerStatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  ConsumerState<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends ConsumerState<CoachHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final coachId = authState.user?.coachId;

    if (coachId == null) {
      return const Center(
        child: Text(
          'Coach ID not found',
          style: TextStyle(color: AppColors.error),
        ),
      );
    }

    final coachStatsAsync = ref.watch(coachStatsProvider(coachId));
    final todaySessionsAsync = ref.watch(coachTodaySessionsProvider(coachId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(coachStatsProvider(coachId));
        ref.invalidate(coachTodaySessionsProvider(coachId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authState.user?.name ?? 'Coach',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Grid
            coachStatsAsync.when(
              data: (stats) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppDimensions.spacingM,
                  mainAxisSpacing: AppDimensions.spacingM,
                  childAspectRatio: 1.1,
                  children: [
                    _StatCard(
                      icon: Icons.groups,
                      value: stats.assignedBatches.toString(),
                      label: 'Assigned Batches',
                      onTap: null,
                    ),
                    _StatCard(
                      icon: Icons.people_outline,
                      value: stats.totalStudents.toString(),
                      label: 'Total Students',
                      onTap: null,
                    ),
                    _StatCard(
                      icon: Icons.calendar_today_outlined,
                      value: stats.sessionsToday.toString(),
                      label: 'Sessions Today',
                      onTap: null,
                    ),
                    _StatCard(
                      icon: Icons.trending_up,
                      value: '${stats.attendanceRate.toStringAsFixed(0)}%',
                      label: 'Attendance Rate',
                      onTap: null,
                    ),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                child: Center(child: LoadingSpinner()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: ErrorDisplay(
                  message: 'Failed to load statistics',
                  onRetry: () => ref.invalidate(coachStatsProvider(coachId)),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Today's Sessions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Sessions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  todaySessionsAsync.when(
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return NeumorphicContainer(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          child: const Center(
                            child: Text(
                              'No sessions scheduled for today',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: sessions.map((session) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                            child: NeumorphicContainer(
                              padding: const EdgeInsets.all(AppDimensions.paddingM),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                      boxShadow: NeumorphicStyles.getInsetShadow(),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          session.startTime.split(':')[0],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          session.startTime.split(':')[1],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.spacingM),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          session.batchName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${session.startTime} - ${session.endTime}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        if (session.location != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                session.location!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.spacingM,
                                      vertical: AppDimensions.spacingS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getSessionStatusColor(session.status),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    ),
                                    child: Text(
                                      session.status.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const NeumorphicContainer(
                      padding: EdgeInsets.all(AppDimensions.paddingL),
                      child: Center(child: LoadingSpinner()),
                    ),
                    error: (error, stack) => NeumorphicContainer(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: ErrorDisplay(
                        message: 'Failed to load sessions',
                        onRetry: () => ref.invalidate(coachTodaySessionsProvider(coachId)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.check_circle_outline,
                          label: 'Mark Attendance',
                          onTap: () {
                            // Switch to attendance tab
                            // This would be handled by the parent CoachDashboard
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.calendar_today_outlined,
                          label: 'View Schedule',
                          onTap: () {
                            // Navigate to schedule screen
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Color _getSessionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return AppColors.accent;
      case 'ongoing':
        return AppColors.success;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  boxShadow: NeumorphicStyles.getInsetShadow(),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.iconPrimary,
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    return onTap != null
        ? GestureDetector(
            onTap: onTap,
            child: card,
          )
        : card;
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.iconPrimary,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Key Features**:
- Welcome header with coach name
- Stats grid (4 cards: Assigned Batches, Total Students, Sessions Today, Attendance Rate)
- Today's sessions list with time, batch name, location, status
- Quick actions (Mark Attendance, View Schedule)
- Pull-to-refresh
- Loading states
- Error handling

**Estimated LOC**: ~450 lines

---

### 4. Coach Batches Screen

**Path**: `lib/screens/coach/coach_batches_screen.dart`

**Purpose**: View all assigned batches with student details (READ-ONLY for coaches)

**Database Tables Used**:
- `batches` (WHERE coach_id = ?)
- `batch_enrollments` (student enrollments)
- `students` (student details)

**API Endpoints**:
- `GET /api/coaches/{coach_id}/batches` - Get assigned batches
- `GET /api/batches/{batch_id}/students` - Get students in batch

**Code**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/batch.dart';

/// Coach Batches Screen - View assigned batches (READ-ONLY)
class CoachBatchesScreen extends ConsumerStatefulWidget {
  const CoachBatchesScreen({super.key});

  @override
  ConsumerState<CoachBatchesScreen> createState() => _CoachBatchesScreenState();
}

class _CoachBatchesScreenState extends ConsumerState<CoachBatchesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final coachId = authState.user?.coachId;

    if (coachId == null) {
      return const Center(
        child: Text(
          'Coach ID not found',
          style: TextStyle(color: AppColors.error),
        ),
      );
    }

    final batchesAsync = ref.watch(coachBatchesProvider(coachId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(coachBatchesProvider(coachId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'My Batches',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Search Bar
              NeumorphicContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.spacingS,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.iconPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Search batches...',
                          hintStyle: TextStyle(color: AppColors.textHint),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Batches List
              batchesAsync.when(
                data: (batches) {
                  if (batches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 80),
                          Icon(
                            Icons.groups_outlined,
                            size: 80,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          const Text(
                            'No batches assigned yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter batches based on search query
                  final filteredBatches = batches.where((batch) {
                    return batch.name.toLowerCase().contains(_searchQuery) ||
                           batch.timeRange.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredBatches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 80),
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          const Text(
                            'No batches match your search',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: filteredBatches.map((batch) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                        child: _BatchCard(
                          batch: batch,
                          onTap: () => _showBatchDetails(batch),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.paddingL),
                    child: LoadingSpinner(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: ErrorDisplay(
                      message: 'Failed to load batches',
                      onRetry: () => ref.invalidate(coachBatchesProvider(coachId)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  void _showBatchDetails(Batch batch) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return _BatchDetailsSheet(
            batch: batch,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback onTap;

  const _BatchCard({
    required this.batch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: NeumorphicStyles.getInsetShadow(),
                  ),
                  child: const Icon(
                    Icons.groups,
                    size: 24,
                    color: AppColors.iconPrimary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        batch.timeRange,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.people_outline,
                  label: '${batch.enrolledCount ?? 0}/${batch.capacity} Students',
                ),
                const SizedBox(width: AppDimensions.spacingM),
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: batch.period,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        boxShadow: NeumorphicStyles.getSmallInsetShadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.iconPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchDetailsSheet extends ConsumerWidget {
  final Batch batch;
  final ScrollController scrollController;

  const _BatchDetailsSheet({
    required this.batch,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(batchStudentsProvider(batch.id));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacingM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              children: [
                // Batch Info
                Text(
                  batch.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Timing',
                  value: batch.timeRange,
                ),
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Period',
                  value: batch.period,
                ),
                _DetailRow(
                  icon: Icons.people,
                  label: 'Capacity',
                  value: '${batch.enrolledCount ?? 0}/${batch.capacity} students',
                ),
                _DetailRow(
                  icon: Icons.attach_money,
                  label: 'Fees',
                  value: '₹${batch.fees} / ${batch.period.toLowerCase()}',
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // Students List
                const Text(
                  'Enrolled Students',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),

                studentsAsync.when(
                  data: (students) {
                    if (students.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingL),
                          child: Text(
                            'No students enrolled yet',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: students.map((student) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                          child: NeumorphicContainer(
                            padding: const EdgeInsets.all(AppDimensions.paddingM),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                                  child: Text(
                                    student.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.spacingM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (student.email != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          student.email!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.paddingL),
                      child: LoadingSpinner(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Text(
                        'Failed to load students',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.iconPrimary,
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Key Features**:
- List of assigned batches
- Search functionality
- Batch cards with icons and info chips
- Batch details bottom sheet with students list
- READ-ONLY (no edit/delete actions)
- Pull-to-refresh
- Loading states
- Empty states
- Error handling

**Estimated LOC**: ~550 lines

---

### 5. Coach Attendance Screen

**Path**: `lib/screens/coach/coach_attendance_screen.dart`

**Purpose**: Mark attendance for assigned batches (CRITICAL FEATURE for coaches)

**Database Tables Used**:
- `batches` (WHERE coach_id = ?)
- `batch_enrollments` (students in batch)
- `students` (student details)
- `attendance` (mark attendance records)

**API Endpoints**:
- `GET /api/coaches/{coach_id}/batches` - Get assigned batches
- `GET /api/batches/{batch_id}/students` - Get students
- `GET /api/attendance/batch/{batch_id}/date/{date}` - Get existing attendance
- `POST /api/attendance/bulk` - Mark attendance for multiple students

**Code**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/coach_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/batch.dart';

/// Coach Attendance Screen - Mark attendance for assigned batches
class CoachAttendanceScreen extends ConsumerStatefulWidget {
  const CoachAttendanceScreen({super.key});

  @override
  ConsumerState<CoachAttendanceScreen> createState() => _CoachAttendanceScreenState();
}

class _CoachAttendanceScreenState extends ConsumerState<CoachAttendanceScreen> {
  int? _selectedBatchId;
  DateTime _selectedDate = DateTime.now();
  final Map<int, String> _attendance = {}; // studentId -> 'present' or 'absent'
  final Map<int, String> _remarks = {}; // studentId -> remarks
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final coachId = authState.user?.coachId;

    if (coachId == null) {
      return const Center(
        child: Text(
          'Coach ID not found',
          style: TextStyle(color: AppColors.error),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Mark Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Date Picker
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.iconPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.accent,
                                  surface: AppColors.cardBackground,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                            _attendance.clear();
                            _remarks.clear();
                          });
                          // Load existing attendance for the selected date
                          if (_selectedBatchId != null) {
                            _loadExistingAttendance();
                          }
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _getFormattedDate(_selectedDate),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Batch Selector or Student List
            if (_selectedBatchId == null)
              _buildBatchSelector(coachId)
            else
              _buildStudentAttendanceList(),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBatchSelector(int coachId) {
    final batchesAsync = ref.watch(coachBatchesProvider(coachId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Batch',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        batchesAsync.when(
          data: (batches) {
            if (batches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Icon(
                      Icons.groups_outlined,
                      size: 80,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    const Text(
                      'No batches assigned',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: batches.map((batch) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    onTap: () {
                      setState(() {
                        _selectedBatchId = batch.id;
                        _attendance.clear();
                        _remarks.clear();
                      });
                      _loadExistingAttendance();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            boxShadow: NeumorphicStyles.getInsetShadow(),
                          ),
                          child: const Icon(
                            Icons.groups,
                            size: 24,
                            color: AppColors.iconPrimary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                batch.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                batch.timeRange,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: LoadingSpinner(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: ErrorDisplay(
                message: 'Failed to load batches',
                onRetry: () => ref.invalidate(coachBatchesProvider(coachId)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentAttendanceList() {
    if (_selectedBatchId == null) return const SizedBox.shrink();

    final studentsAsync = ref.watch(batchStudentsProvider(_selectedBatchId!));
    final batchesAsync = ref.watch(coachBatchesProvider(
      ref.watch(authProvider).user?.coachId ?? 0,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _selectedBatchId = null;
                  _attendance.clear();
                  _remarks.clear();
                });
              },
            ),
            Expanded(
              child: Text(
                batchesAsync.value?.firstWhere((b) => b.id == _selectedBatchId)?.name ?? 'Batch',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Quick Actions
        Row(
          children: [
            Expanded(
              child: _QuickMarkButton(
                label: 'Mark All Present',
                icon: Icons.check_circle,
                color: AppColors.success,
                onTap: () {
                  final students = studentsAsync.value ?? [];
                  setState(() {
                    for (final student in students) {
                      _attendance[student.id] = 'present';
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: _QuickMarkButton(
                label: 'Mark All Absent',
                icon: Icons.cancel,
                color: AppColors.error,
                onTap: () {
                  final students = studentsAsync.value ?? [];
                  setState(() {
                    for (final student in students) {
                      _attendance[student.id] = 'absent';
                    }
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingL),

        // Students List
        studentsAsync.when(
          data: (students) {
            if (students.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingL),
                  child: Text(
                    'No students enrolled in this batch',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                ...students.map((student) {
                  final attendanceStatus = _attendance[student.id];
                  return _AttendanceItem(
                    name: student.name,
                    isPresent: attendanceStatus == 'present',
                    hasSelection: attendanceStatus != null,
                    remark: _remarks[student.id] ?? '',
                    onPresentChanged: (isPresent) {
                      setState(() {
                        _attendance[student.id] = isPresent ? 'present' : 'absent';
                      });
                    },
                    onRemarkChanged: (remark) {
                      setState(() {
                        _remarks[student.id] = remark;
                      });
                    },
                  );
                }),

                // Summary & Save
                if (_attendance.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingL),
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SummaryItem(
                              label: 'Present',
                              value: _attendance.values.where((v) => v == 'present').length.toString(),
                              color: AppColors.success,
                            ),
                            _SummaryItem(
                              label: 'Absent',
                              value: _attendance.values.where((v) => v == 'absent').length.toString(),
                              color: AppColors.error,
                            ),
                            _SummaryItem(
                              label: 'Total',
                              value: students.length.toString(),
                              color: AppColors.textSecondary,
                            ),
                            _SummaryItem(
                              label: 'Rate',
                              value: '${((_attendance.values.where((v) => v == 'present').length / _attendance.length) * 100).toStringAsFixed(0)}%',
                              color: AppColors.iconPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveAttendance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Save Attendance',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: LoadingSpinner(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: ErrorDisplay(
                message: 'Failed to load students',
                onRetry: () => ref.invalidate(batchStudentsProvider(_selectedBatchId!)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedBatchId == null) return;

    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      final existingAttendance = await attendanceService.getAttendance(
        date: _selectedDate,
        batchId: _selectedBatchId,
      );

      if (mounted) {
        setState(() {
          for (final record in existingAttendance) {
            _attendance[record.studentId] = record.status;
            if (record.remarks != null) {
              _remarks[record.studentId] = record.remarks!;
            }
          }
        });
      }
    } catch (e) {
      // Silently fail - user can mark attendance fresh
    }
  }

  Future<void> _saveAttendance() async {
    if (_attendance.isEmpty || _selectedBatchId == null) return;

    setState(() => _isSaving = true);

    try {
      final attendanceService = ref.read(attendanceServiceProvider);

      // Save attendance for all marked students
      for (final entry in _attendance.entries) {
        await attendanceService.markStudentAttendance(
          studentId: entry.key,
          batchId: _selectedBatchId!,
          date: _selectedDate,
          status: entry.value,
          remarks: _remarks[entry.key],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );

        // Clear attendance after saving
        setState(() {
          _attendance.clear();
          _remarks.clear();
          _selectedBatchId = null;
        });

        // Invalidate providers to refresh data
        ref.invalidate(coachStatsProvider(
          ref.read(authProvider).user?.coachId ?? 0,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _getFormattedDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _QuickMarkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickMarkButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceItem extends StatelessWidget {
  final String name;
  final bool isPresent;
  final bool hasSelection;
  final String remark;
  final ValueChanged<bool> onPresentChanged;
  final ValueChanged<String> onRemarkChanged;

  const _AttendanceItem({
    required this.name,
    required this.isPresent,
    this.hasSelection = false,
    required this.remark,
    required this.onPresentChanged,
    required this.onRemarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Present Button
              GestureDetector(
                onTap: () => onPresentChanged(true),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasSelection && isPresent
                        ? AppColors.success
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: hasSelection && isPresent
                        ? NeumorphicStyles.getInsetShadow()
                        : NeumorphicStyles.getElevatedShadow(),
                  ),
                  child: Icon(
                    Icons.check,
                    color: hasSelection && isPresent
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Absent Button
              GestureDetector(
                onTap: () => onPresentChanged(false),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasSelection && !isPresent
                        ? AppColors.error
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: hasSelection && !isPresent
                        ? NeumorphicStyles.getInsetShadow()
                        : NeumorphicStyles.getElevatedShadow(),
                  ),
                  child: Icon(
                    Icons.close,
                    color: hasSelection && !isPresent
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              boxShadow: NeumorphicStyles.getSmallInsetShadow(),
            ),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Add remarks (optional)...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onRemarkChanged,
              controller: TextEditingController(text: remark)
                ..selection = TextSelection.collapsed(offset: remark.length),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
```

**Key Features**:
- Date picker (past and today only)
- Batch selection
- Student list with present/absent buttons
- Quick mark all present/absent
- Remarks for each student
- Summary (Present, Absent, Total, Rate)
- Save attendance (bulk API call)
- Load existing attendance if already marked
- Pull-to-refresh
- Loading states
- Error handling
- Success/error snackbars

**Estimated LOC**: ~700 lines

---

### 6. Coach Announcements Screen

**Path**: `lib/screens/coach/coach_announcements_screen.dart`

**Purpose**: View announcements from academy (READ-ONLY for coaches)

**Database Tables Used**:
- `announcements` (all announcements or targeted to coaches)

**API Endpoints**:
- `GET /api/announcements?audience=coach` - Get announcements for coaches

**Code**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement.dart';

/// Coach Announcements Screen - View announcements (READ-ONLY)
class CoachAnnouncementsScreen extends ConsumerWidget {
  const CoachAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(coachAnnouncementsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppColors.backgroundGradient
              : AppColorsLight.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(coachAnnouncementsProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Text(
                              'Announcements',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Announcements List
                announcementsAsync.when(
                  data: (announcements) {
                    if (announcements.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.campaign_outlined,
                                size: 80,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: AppDimensions.spacingM),
                              const Text(
                                'No announcements yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final announcement = announcements[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                              child: _AnnouncementCard(announcement: announcement),
                            );
                          },
                          childCount: announcements.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: LoadingSpinner()),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: ErrorDisplay(
                          message: 'Failed to load announcements',
                          onRetry: () => ref.invalidate(coachAnnouncementsProvider),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPriorityColor(announcement.priority).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  _getPriorityIcon(announcement.priority),
                  size: 20,
                  color: _getPriorityColor(announcement.priority),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFormattedDate(announcement.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (announcement.priority == 'urgent')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Content
          Text(
            announcement.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          // Target Audience Tag
          if (announcement.targetAudience != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: NeumorphicStyles.getSmallInsetShadow(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getAudienceIcon(announcement.targetAudience!),
                        size: 12,
                        color: AppColors.iconPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.targetAudience!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'normal':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPriorityIcon(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return Icons.error_outline;
      case 'high':
        return Icons.priority_high;
      case 'normal':
        return Icons.info_outline;
      default:
        return Icons.campaign_outlined;
    }
  }

  IconData _getAudienceIcon(String audience) {
    switch (audience.toLowerCase()) {
      case 'coach':
      case 'coaches':
        return Icons.person_outline;
      case 'student':
      case 'students':
        return Icons.school_outlined;
      case 'all':
        return Icons.groups;
      default:
        return Icons.people_outline;
    }
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
```

**Key Features**:
- List of announcements with priority indicators
- Priority colors (urgent=red, high=yellow, normal=blue)
- Target audience tags
- Formatted timestamps (relative: "2h ago", "3d ago")
- READ-ONLY (no create/edit/delete)
- Pull-to-refresh
- Loading states
- Empty state
- Error handling

**Estimated LOC**: ~450 lines

---

### 7. Coach Schedule Screen

**Path**: `lib/screens/coach/coach_schedule_screen.dart`

**Purpose**: View upcoming sessions and schedule (optional feature)

**Database Tables Used**:
- `schedules` (WHERE coach_id = ?)
- `batches` (batch details)

**API Endpoints**:
- `GET /api/coaches/{coach_id}/schedule` - Get coach's schedule
- `GET /api/schedules/coach/{coach_id}/week` - Get week view

**Code**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/schedule.dart';

/// Coach Schedule Screen - View sessions calendar
class CoachScheduleScreen extends ConsumerStatefulWidget {
  const CoachScheduleScreen({super.key});

  @override
  ConsumerState<CoachScheduleScreen> createState() => _CoachScheduleScreenState();
}

class _CoachScheduleScreenState extends ConsumerState<CoachScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final coachId = authState.user?.coachId;

    if (coachId == null) {
      return const Center(
        child: Text(
          'Coach ID not found',
          style: TextStyle(color: AppColors.error),
        ),
      );
    }

    final scheduleAsync = ref.watch(coachScheduleProvider(coachId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppColors.backgroundGradient
              : AppColorsLight.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'My Schedule',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingS),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                      weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.iconPrimary,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.iconPrimary,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      weekendStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    eventLoader: (day) {
                      // Return events for this day
                      final schedule = scheduleAsync.value;
                      if (schedule == null) return [];

                      return schedule.where((session) {
                        return isSameDay(session.date, day);
                      }).toList();
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Sessions for Selected Day
              Expanded(
                child: scheduleAsync.when(
                  data: (sessions) {
                    final selectedDate = _selectedDay ?? _focusedDay;
                    final daySession = sessions.where((session) {
                      return isSameDay(session.date, selectedDate);
                    }).toList();

                    if (daySession.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 60,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppDimensions.spacingM),
                            const Text(
                              'No sessions scheduled',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      itemCount: daySessions.length,
                      itemBuilder: (context, index) {
                        final session = daySessions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                          child: _SessionCard(session: session),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: LoadingSpinner()),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: ErrorDisplay(
                        message: 'Failed to load schedule',
                        onRetry: () => ref.invalidate(coachScheduleProvider(coachId)),
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
}

class _SessionCard extends StatelessWidget {
  final Schedule session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          // Time
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              boxShadow: NeumorphicStyles.getInsetShadow(),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  session.startTime.split(':')[0],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  session.startTime.split(':')[1],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.spacingM),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.batchName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.startTime} - ${session.endTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (session.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session.location!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(session.status),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              session.status.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return AppColors.accent;
      case 'ongoing':
        return AppColors.success;
      case 'completed':
        return AppColors.textSecondary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
```

**Key Features**:
- Week/month calendar view (table_calendar package)
- Day selector
- Sessions list for selected day
- Session cards with time, batch, location, status
- Event markers on calendar dates
- Loading states
- Empty state
- Error handling

**Estimated LOC**: ~450 lines

**Note**: Requires `table_calendar` package in `pubspec.yaml`:
```yaml
dependencies:
  table_calendar: ^3.0.9
```

---

