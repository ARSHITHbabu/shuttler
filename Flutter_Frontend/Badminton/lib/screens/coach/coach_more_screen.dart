import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Coach More Screen - Placeholder
/// TODO: Implement full functionality
class CoachMoreScreen extends StatelessWidget {
  const CoachMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text(
          'Coach More Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
