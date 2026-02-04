import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/skeleton_screen.dart';
import '../../../widgets/common/success_snackbar.dart';
import '../../../providers/batch_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../models/coach.dart';

/// Batches Tab - Shows batches assigned to the coach and allows management
class CoachBatchesTab extends ConsumerStatefulWidget {
  final Coach coach;

  const CoachBatchesTab({
    super.key,
    required this.coach,
  });

  @override
  ConsumerState<CoachBatchesTab> createState() => _CoachBatchesTabState();
}

class _CoachBatchesTabState extends ConsumerState<CoachBatchesTab> {
  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(batchListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assigned Batches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _manageBatches(),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Batches'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
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
                  .where((batch) => batch.assignedCoachIds.contains(widget.coach.id))
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
                            Expanded(
                              child: Text(
                                batch.timing,
                                style: const TextStyle(color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: AppDimensions.spacingS),
                            Expanded(
                              child: Text(
                                batch.period,
                                style: const TextStyle(color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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

  void _manageBatches() async {
    try {
      final allBatches = await ref.read(batchListProvider.future);
      final assignedBatches = allBatches
          .where((batch) => batch.assignedCoachIds.contains(widget.coach.id))
          .toList();
      
      if (allBatches.isEmpty) {
        SuccessSnackbar.showInfo(context, 'No batches available. Please create a batch first.');
        return;
      }

      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Manage Batches', style: TextStyle(color: AppColors.textPrimary)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Batches:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    if (assignedBatches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingS),
                        child: Text(
                          'No batches assigned',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      )
                    else
                      ...assignedBatches.map((batch) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                          padding: const EdgeInsets.all(AppDimensions.paddingS),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  batch.batchName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                                onPressed: () async {
                                  try {
                                    await _removeCoachFromBatch(batch.id);
                                    if (mounted && Navigator.of(dialogContext).canPop()) {
                                      Navigator.of(dialogContext).pop();
                                      SuccessSnackbar.show(context, 'Coach removed from batch successfully');
                                    }
                                  } catch (e) {
                                    final errorMessage = e.toString().replaceFirst('Exception: ', '');
                                    SuccessSnackbar.showError(context, 'Failed to remove from batch: $errorMessage');
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: AppDimensions.spacingM),
                    const Divider(color: AppColors.textSecondary),
                    const SizedBox(height: AppDimensions.spacingM),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await _showAddBatchDialog(assignedBatches);
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Batch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      SuccessSnackbar.showError(context, 'Failed to load batches: ${e.toString()}');
    }
  }

  Future<void> _showAddBatchDialog(List batches) async {
    try {
      final allBatches = await ref.read(batchListProvider.future);
      
      if (allBatches.isEmpty) {
        SuccessSnackbar.showInfo(context, 'No batches available. Please create a batch first.');
        return;
      }

      final existingBatchIds = batches.map((b) => b.id).toSet();
      final availableBatches = allBatches.where((b) => !existingBatchIds.contains(b.id)).toList();

      if (availableBatches.isEmpty) {
        SuccessSnackbar.showInfo(context, 'Coach is already assigned to all available batches.');
        return;
      }

      final selectedBatchIdNotifier = ValueNotifier<int?>(null);
      
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Add Batch', style: TextStyle(color: AppColors.textPrimary)),
          content: ValueListenableBuilder<int?>(
            valueListenable: selectedBatchIdNotifier,
            builder: (context, selectedBatchId, _) {
              return DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Select Batch',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                items: availableBatches.map((batch) {
                  return DropdownMenuItem<int>(
                    value: batch.id,
                    child: Text(batch.batchName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedBatchIdNotifier.value = value;
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<int?>(
              valueListenable: selectedBatchIdNotifier,
              builder: (context, selectedBatchId, _) {
                return TextButton(
                  onPressed: selectedBatchId == null
                      ? null
                      : () async {
                          try {
                            await _addCoachToBatch(selectedBatchId);
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              SuccessSnackbar.show(context, 'Coach assigned to batch successfully');
                            }
                          } catch (e) {
                            final errorMessage = e.toString().replaceFirst('Exception: ', '');
                            SuccessSnackbar.showError(context, 'Failed to add batch: $errorMessage');
                          }
                        },
                  child: const Text('Add Batch'),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      SuccessSnackbar.showError(context, 'Failed to load batches: $errorMessage');
    }
  }

  Future<void> _addCoachToBatch(int batchId) async {
    final batchService = ref.read(batchServiceProvider);
    final allBatches = await ref.read(batchListProvider.future);
    final batch = allBatches.firstWhere((b) => b.id == batchId);
    
    // Add coach to the batch's assigned coaches list
    final updatedCoachIds = [...batch.assignedCoachIds, widget.coach.id];
    
    await batchService.updateBatch(batchId, {
      'assigned_coach_ids': updatedCoachIds,
    });
    
    // Refresh the batch list
    ref.invalidate(batchListProvider);
  }

  Future<void> _removeCoachFromBatch(int batchId) async {
    final batchService = ref.read(batchServiceProvider);
    final allBatches = await ref.read(batchListProvider.future);
    final batch = allBatches.firstWhere((b) => b.id == batchId);
    
    // Remove coach from the batch's assigned coaches list
    final updatedCoachIds = batch.assignedCoachIds.where((id) => id != widget.coach.id).toList();
    
    await batchService.updateBatch(batchId, {
      'assigned_coach_ids': updatedCoachIds,
    });
    
    // Refresh the batch list
    ref.invalidate(batchListProvider);
  }
}
