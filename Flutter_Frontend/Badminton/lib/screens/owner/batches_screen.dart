import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/batch_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/dialogs/batch_details_dialog.dart';
import '../../widgets/batch/batch_students_sheet.dart';
import '../../models/batch.dart';
import '../../models/coach.dart';
import '../../models/student.dart';
import '../../core/constants/api_endpoints.dart';

/// Batches Screen - List and manage batches
/// Matches React reference: BatchesScreen.tsx
class BatchesScreen extends ConsumerStatefulWidget {
  const BatchesScreen({super.key});

  @override
  ConsumerState<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends ConsumerState<BatchesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  void _openAddForm() {
    BatchDetailsDialog.show(context, isOwner: true);
  }

  void _openEditForm(Batch batch) {
    BatchDetailsDialog.show(context, batch: batch, isOwner: true);
  }


  Future<void> _deleteBatch(Batch batch) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Batch', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose how you want to remove ${batch.name}:',
                style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _DeleteOption(
              title: 'Deactivate (Soft Delete)',
              description: 'Hide batch from UI but keep historical data for reports.',
              icon: Icons.pause_circle_outline,
              color: AppColors.warning,
              onTap: () {
                Navigator.pop(context);
                _handleDeactivateBatch(batch);
              },
            ),
            const SizedBox(height: 12),
            _DeleteOption(
              title: 'Delete Permanently (Hard Delete)',
              description: 'Immediately wipe all batch data and student associations.',
              icon: Icons.delete_forever,
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _handleRemoveBatchPermanently(batch);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleDeactivateBatch(Batch batch) async {
    try {
      await ref.read(batchListProvider.notifier).deactivateBatch(batch.id);
      if (mounted) {
        SuccessSnackbar.show(context, 'Batch deactivated successfully');
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to deactivate batch: ${e.toString()}');
      }
    }
  }

  void _handleRemoveBatchPermanently(Batch batch) async {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Permanent Deletion',
        message: 'This action CANNOT be undone. All data for ${batch.name} will be permanently destroyed. Are you absolutely sure?',
        confirmLabel: 'Delete Forever',
        isDangerous: true,
        onConfirm: () async {
          try {
            await ref.read(batchListProvider.notifier).removeBatchPermanently(batch.id);
            if (mounted) {
              SuccessSnackbar.show(context, 'Batch deleted permanently');
            }
          } catch (e) {
            if (mounted) {
              SuccessSnackbar.showError(context, 'Failed to delete batch: ${e.toString()}');
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(batchListProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(batchListProvider.notifier).refresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Batches',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.textPrimary),
                        onPressed: _openAddForm,
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                  child: NeumorphicInsetContainer(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: AppDimensions.spacingS),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Search batches...',
                              hintStyle: TextStyle(color: AppColors.textHint),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) => setState(() => _searchQuery = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // Batches List
                batchesAsync.when(
                  data: (batches) {
                    final filteredBatches = batches.where((batch) {
                      if (_searchQuery.isEmpty) return true;
                      return batch.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    if (filteredBatches.isEmpty) {
                      return EmptyState.noBatches(
                        onCreate: _searchQuery.isEmpty ? _openAddForm : null,
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      child: Column(
                        children: filteredBatches.map((batch) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                          child: _BatchCard(
                            batch: batch,
                            onTap: () => _openEditForm(batch),
                            onEdit: () => _openEditForm(batch),
                            onDelete: () => _deleteBatch(batch),
                            onViewStudents: () => BatchStudentsSheet.show(context, batch),
                          ),
                        )).toList(),
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppDimensions.paddingL),
                    child: ListSkeleton(itemCount: 5),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: ErrorDisplay(
                      message: 'Failed to load batches. Please check your connection and try again.',
                      onRetry: () => ref.read(batchListProvider.notifier).refresh(),
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewStudents;

  const _BatchCard({
    required this.batch,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onViewStudents,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          batch.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: batch.status == 'active' ? AppColors.success : AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            batch.status.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(batch.timeRange, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                color: AppColors.cardBackground,
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  else if (value == 'delete') onDelete();
                  else if (value == 'students') onViewStudents();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppColors.textPrimary))),
                  const PopupMenuItem(value: 'students', child: Text('View Students', style: TextStyle(color: AppColors.textPrimary))),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _InfoChip(icon: Icons.calendar_today_outlined, label: batch.daysString),
          if (batch.assignedCoachIds.isNotEmpty || batch.assignedCoachId != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            _InfoChip(
              icon: Icons.person_outline,
              label: batch.coachNamesString.isNotEmpty ? batch.coachNamesString : (batch.coachName ?? 'Coach'),
            ),
          ],
          if (batch.location != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            _InfoChip(icon: Icons.location_on_outlined, label: batch.location!),
          ],
          const SizedBox(height: AppDimensions.spacingS),
          Text('Capacity: ${batch.capacity}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
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
        horizontal: AppDimensions.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        boxShadow: NeumorphicStyles.getSmallInsetShadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
  }
}

class _DeleteOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DeleteOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
