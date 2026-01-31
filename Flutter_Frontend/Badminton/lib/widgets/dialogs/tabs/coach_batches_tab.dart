import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/skeleton_screen.dart'; // Assuming ListSkeleton is here
import '../../../providers/batch_provider.dart';
import '../../../models/coach.dart';

/// Batches Tab - Shows batches assigned to the coach
class CoachBatchesTab extends ConsumerWidget {
  final Coach coach;

  const CoachBatchesTab({
    super.key,
    required this.coach,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Batches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          batchesAsync.when(
            loading: () => const ListSkeleton(itemCount: 3),
            error: (error, stack) => ErrorDisplay(
              message: 'Failed to load batches: ${error.toString()}',
              onRetry: () => ref.invalidate(batchListProvider),
            ),
            data: (allBatches) {
              final assignedBatches = allBatches
                  .where((batch) => batch.assignedCoachId == coach.id)
                  .toList();

              if (assignedBatches.isEmpty) {
                return NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: AppDimensions.spacingM),
                        Text(
                          'No batches assigned to this coach',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: assignedBatches.map((batch) {
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
                                batch.batchName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: AppDimensions.spacingS),
                            Text(
                              batch.timing,
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: AppDimensions.spacingM),
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: AppDimensions.spacingS),
                            Text(
                              batch.period,
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        /*
                        // Capacity is non-nullable int, no need to check for null
                        const SizedBox(height: AppDimensions.spacingS),
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: AppDimensions.spacingS),
                            Text(
                              'Capacity: ${batch.capacity}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        */
                        const SizedBox(height: AppDimensions.spacingS),
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: AppDimensions.spacingS),
                              Text(
                                'Capacity: ${batch.capacity}',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
