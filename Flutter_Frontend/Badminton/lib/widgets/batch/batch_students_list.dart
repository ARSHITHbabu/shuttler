import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/batch_provider.dart';
import '../../models/batch.dart';
import '../../models/student.dart';
import 'batch_students_sheet.dart';

/// A standalone widget for displaying and managing students in a batch
class BatchStudentsList extends ConsumerStatefulWidget {
  final Batch batch;
  final bool isOwner;

  const BatchStudentsList({
    super.key,
    required this.batch,
    required this.isOwner,
  });

  @override
  ConsumerState<BatchStudentsList> createState() => _BatchStudentsListState();
}

class _BatchStudentsListState extends ConsumerState<BatchStudentsList> {
  bool _isRemoving = false;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(batchStudentsProvider(widget.batch.id));

    return studentsAsync.when(
      loading: () => const Center(child: ListSkeleton(itemCount: 5)),
      error: (error, stack) => ErrorDisplay(
        message: 'Failed to load students: ${error.toString()}',
        onRetry: () => ref.invalidate(batchStudentsProvider(widget.batch.id)),
      ),
      data: (students) {
        if (students.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.paddingL),
              const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: AppDimensions.spacingM),
              const Text(
                'No students in this batch',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              if (widget.isOwner) ...[
                const SizedBox(height: AppDimensions.spacingM),
                TextButton.icon(
                  onPressed: () => AddStudentsSheet.show(context, widget.batch),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Students'),
                ),
              ],
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.background,
                      child: Text(
                        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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
                          if (student.phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              student.phone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.isOwner)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: _isRemoving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                        onPressed: _isRemoving ? null : () => _removeStudent(student),
                        tooltip: 'Remove from batch',
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _removeStudent(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Remove Student', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Are you sure you want to remove ${student.name} from this batch?', 
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRemoving = true);

    try {
      await ref.read(batchListProvider.notifier).removeStudent(
        widget.batch.id,
        student.id,
      );
      if (mounted) {
        SuccessSnackbar.show(context, '${student.name} removed from batch');
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to remove student: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isRemoving = false);
      }
    }
  }
}
