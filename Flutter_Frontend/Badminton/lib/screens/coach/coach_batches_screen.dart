import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Coach Batches Screen - Placeholder
/// TODO: Implement full functionality
class CoachBatchesScreen extends StatelessWidget {
  const CoachBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text(
          'Coach Batches Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
