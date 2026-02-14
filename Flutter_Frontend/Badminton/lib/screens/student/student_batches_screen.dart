import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/batch_provider.dart';
import '../../widgets/dialogs/batch_details_dialog.dart';
import '../../models/batch.dart';

/// Student Batches Screen - View enrolled batches
class StudentBatchesScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const StudentBatchesScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentBatchesScreen> createState() => _StudentBatchesScreenState();
}

class _StudentBatchesScreenState extends ConsumerState<StudentBatchesScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Batches',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: authState.when(
        data: (authValue) {
          if (authValue is! Authenticated) {
            return const Center(child: Text('Please log in to view batches'));
          }

          final studentId = authValue.userId;
          final batchesAsync = ref.watch(studentBatchesProvider(studentId));

          return batchesAsync.when(
            data: (batches) {
              if (batches.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_off_outlined,
                        size: 64,
                        color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'You are not enrolled in any batches yet.',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final batch = batches[index];
                  return _StudentBatchCard(
                    batch: batch,
                    onTap: () => _showBatchDetails(batch),
                    isSmallScreen: isSmallScreen,
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: ListSkeleton(itemCount: 3),
            ),
            error: (error, stack) => Center(
              child: ErrorDisplay(
                message: 'Failed to load batches. Please try again.',
                onRetry: () => ref.refresh(studentBatchesProvider(studentId)),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showBatchDetails(Batch batch) {
    BatchDetailsDialog.show(context, batch: batch, isOwner: false);
  }
}

class _StudentBatchCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _StudentBatchCard({
    required this.batch,
    required this.onTap,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return NeumorphicContainer(
      margin: EdgeInsets.only(bottom: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  batch.batchName,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            batch.period,
            isDark,
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 6 : AppDimensions.spacingXs),
          _buildInfoRow(
            Icons.access_time_outlined,
            batch.timing,
            isDark,
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 6 : AppDimensions.spacingXs),
          _buildInfoRow(
            Icons.person_outline,
            'Coach: ${batch.coachName ?? "Not assigned"}',
            isDark,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 14 : 16,
          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
        ),
        SizedBox(width: isSmallScreen ? 6 : AppDimensions.spacingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
