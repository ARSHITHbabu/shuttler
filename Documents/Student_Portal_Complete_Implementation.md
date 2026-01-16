# Student Portal - Complete Implementation Guide
## All Screens with Uniform Design from Owner Portal

> **Complete implementation from login to settings**
> **Following exact neumorphic design system from owner portal**
> **All screens with database integration and API calls**
> **READ-ONLY access with view permissions only**

---

## Table of Contents
1. [Design System Reference](#design-system-reference)
2. [Screen Architecture](#screen-architecture)
3. [Screen Implementations](#screen-implementations)
   - [1. Login Screen](#1-login-screen)
   - [2. Profile Completion Screen](#2-profile-completion-screen)
   - [3. Student Dashboard (Container)](#3-student-dashboard-container)
   - [4. Student Home Screen](#4-student-home-screen)
   - [5. Student Attendance Screen](#5-student-attendance-screen)
   - [6. Student Fees Screen](#6-student-fees-screen)
   - [7. Student Performance Screen](#7-student-performance-screen)
   - [8. Student BMI Screen](#8-student-bmi-screen)
   - [9. Student Announcements Screen](#9-student-announcements-screen)
   - [10. Student Schedule Screen](#10-student-schedule-screen)
   - [11. Student Profile Screen](#11-student-profile-screen)
   - [12. Student Settings Screen](#12-student-settings-screen)
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
Student Portal
├── Login Screen (Separate, not in dashboard)
├── Profile Completion Screen (First time only)
└── Student Dashboard (Bottom Navigation Container)
    ├── Home (Index 0)
    ├── Attendance (Index 1)
    ├── Performance (Index 2)
    └── More (Index 3)
        ├── Fees
        ├── BMI Tracking
        ├── Announcements
        ├── Schedule
        ├── Profile
        └── Settings (with Logout)
```

### File Structure
```
lib/screens/student/
├── student_dashboard.dart              # Bottom nav container
├── student_home_screen.dart            # Dashboard overview
├── student_attendance_screen.dart      # View attendance history
├── student_fees_screen.dart            # View fee status
├── student_performance_screen.dart     # View performance records
├── student_bmi_screen.dart             # View BMI records
├── student_announcements_screen.dart   # View announcements
├── student_schedule_screen.dart        # View sessions
├── student_profile_screen.dart         # Edit profile
├── student_settings_screen.dart        # App settings
├── student_more_screen.dart            # More menu
└── profile_completion_screen.dart      # First-time profile setup
```

---

## Screen Implementations

### 1. Login Screen

**Path**: `lib/screens/auth/login_screen.dart`

**Note**: Login screen already exists and handles student login with `userType: 'student'`. After successful authentication, it checks `profile_complete` flag:
- If `profile_complete = false`: Routes to `/student-profile-complete`
- If `profile_complete = true`: Routes to `/student-dashboard`

**Already Implemented**: ✓ This screen already exists and supports student login

---

### 2. Profile Completion Screen

**Path**: `lib/screens/student/profile_completion_screen.dart`

**Purpose**: First-time profile setup after signup (mandatory before accessing dashboard)

**Database Tables Used**:
- `students` (student details)
- `users` (user account)

**API Endpoints**:
- `GET /api/students/{student_id}` - Get student profile
- `PUT /api/students/{student_id}/complete-profile` - Complete profile

**Code**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/student_provider.dart';
import '../../providers/auth_provider.dart';

/// Profile Completion Screen - First-time setup
class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends ConsumerState<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyNameController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
        _dateOfBirth = date;
      });
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final studentId = authState.user?.studentId;

      if (studentId == null) {
        throw Exception('Student ID not found');
      }

      await ref.read(studentServiceProvider).completeProfile(
        studentId: studentId,
        data: {
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'date_of_birth': _dateOfBirth!.toIso8601String().split('T')[0],
          'gender': _gender,
          'emergency_contact_name': _emergencyNameController.text.trim(),
          'emergency_contact_phone': _emergencyContactController.text.trim(),
        },
      );

      if (mounted) {
        context.go('/student-dashboard');
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Text(
                    'Complete Your Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  const Text(
                    'Please provide additional information to complete your profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXxl),

                  // Phone Number
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.length < 10) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Date of Birth
                  GestureDetector(
                    onTap: _isLoading ? null : _selectDateOfBirth,
                    child: NeumorphicContainer(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date of Birth',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _dateOfBirth == null
                                      ? 'Select your date of birth'
                                      : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _dateOfBirth == null
                                        ? AppColors.textHint
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
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
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Gender Selection
                  const Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderButton(
                          label: 'Male',
                          icon: Icons.male,
                          isSelected: _gender == 'male',
                          onTap: _isLoading
                              ? null
                              : () => setState(() => _gender = 'male'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: _GenderButton(
                          label: 'Female',
                          icon: Icons.female,
                          isSelected: _gender == 'female',
                          onTap: _isLoading
                              ? null
                              : () => setState(() => _gender = 'female'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: _GenderButton(
                          label: 'Other',
                          icon: Icons.transgender,
                          isSelected: _gender == 'other',
                          onTap: _isLoading
                              ? null
                              : () => setState(() => _gender = 'other'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Address
                  CustomTextField(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'Enter your address',
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Emergency Contact Name
                  CustomTextField(
                    controller: _emergencyNameController,
                    label: 'Emergency Contact Name',
                    hint: 'Name of emergency contact',
                    prefixIcon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Emergency contact name is required';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Emergency Contact Phone
                  CustomTextField(
                    controller: _emergencyContactController,
                    label: 'Emergency Contact Phone',
                    hint: 'Phone number of emergency contact',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_in_talk_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Emergency contact phone is required';
                      }
                      if (value.length < 10) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Complete Profile Button
                  NeumorphicButton(
                    text: _isLoading ? 'Completing Profile...' : 'Complete Profile',
                    onPressed: _isLoading ? null : _completeProfile,
                    isAccent: true,
                    icon: _isLoading ? null : Icons.check_circle,
                  ),

                  // Loading Overlay
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: AppDimensions.spacingL),
                      child: Center(
                        child: LoadingSpinner(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.onTap,
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
              size: 32,
              color: isSelected ? AppColors.accent : AppColors.iconPrimary,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Key Features**:
- Phone number input
- Date of birth picker
- Gender selection (Male/Female/Other)
- Address input (multiline)
- Emergency contact details (name & phone)
- Form validation
- Loading states
- Success/error feedback
- Navigates to dashboard after completion

**Estimated LOC**: ~400 lines

---

### 3. Student Dashboard (Container)

**Path**: `lib/screens/student/student_dashboard.dart`

**Purpose**: Main container with bottom navigation (mirrors owner_dashboard.dart)

**Code**:
```dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import 'student_home_screen.dart';
import 'student_attendance_screen.dart';
import 'student_performance_screen.dart';
import 'student_more_screen.dart';

/// Student Dashboard with bottom navigation
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

  final List<_BottomNavItem> _navItems = [
    _BottomNavItem(icon: Icons.home, label: 'Home'),
    _BottomNavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    _BottomNavItem(icon: Icons.trending_up, label: 'Performance'),
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

### 4. Student Home Screen

**Path**: `lib/screens/student/student_home_screen.dart`

**Purpose**: Dashboard overview showing student stats, upcoming sessions, and quick stats

**Database Tables Used**:
- `students` (student details)
- `batch_enrollments` (enrolled batches)
- `attendance` (attendance stats)
- `performance_records` (latest performance)
- `bmi_records` (latest BMI)
- `fees` (fee status)
- `schedules` (upcoming sessions)

**API Endpoints**:
- `GET /api/students/{student_id}` - Get student details
- `GET /api/students/{student_id}/stats` - Get statistics
- `GET /api/students/{student_id}/upcoming-sessions` - Get upcoming sessions

**Key Features**:
- Welcome header with student name
- Stats grid (4 cards: Attendance Rate, Performance Score, BMI Status, Fee Status)
- Upcoming sessions list with time, batch name, location
- Quick insights (attendance trend, performance trend)
- Quick actions (View Attendance, View Performance)
- Pull-to-refresh
- Loading states
- Error handling

**Estimated LOC**: ~500 lines

---

