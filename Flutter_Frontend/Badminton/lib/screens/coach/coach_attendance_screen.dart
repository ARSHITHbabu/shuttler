import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Coach Attendance Screen - Placeholder
/// TODO: Implement full functionality
class CoachAttendanceScreen extends StatelessWidget {
  const CoachAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text(
          'Coach Attendance Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
