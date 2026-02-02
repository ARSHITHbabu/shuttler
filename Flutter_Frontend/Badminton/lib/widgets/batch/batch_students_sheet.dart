import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/batch_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/batch.dart';
import '../../models/student.dart';

/// Bottom sheet for managing students in a batch
class BatchStudentsSheet extends ConsumerStatefulWidget {
  final Batch batch;

  const BatchStudentsSheet({super.key, required this.batch});

  /// Show the sheet
  static Future<void> show(BuildContext context, Batch batch) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BatchStudentsSheet(batch: batch),
    );
  }

  @override
  ConsumerState<BatchStudentsSheet> createState() => _BatchStudentsSheetState();
}

class _BatchStudentsSheetState extends ConsumerState<BatchStudentsSheet> {
  bool _isRemoving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.batch.batchName} - Students',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add, color: AppColors.accent),
                      onPressed: () => AddStudentsSheet.show(context, widget.batch),
                      tooltip: 'Add Students',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Students List
          Expanded(
            child: _buildStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
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
              EmptyState.noStudents(),
              const SizedBox(height: AppDimensions.spacingM),
              TextButton.icon(
                onPressed: () => AddStudentsSheet.show(context, widget.batch),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Students'),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                      radius: 24,
                      backgroundColor: AppColors.background,
                      child: Text(
                        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 18,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (student.phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              student.phone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: _isRemoving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.remove_circle_outline, color: AppColors.error),
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
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove ${student.name} from this batch?'),
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

/// Sheet for adding students to a batch
class AddStudentsSheet extends ConsumerStatefulWidget {
  final Batch batch;

  const AddStudentsSheet({super.key, required this.batch});

  /// Show the sheet
  static Future<void> show(BuildContext context, Batch batch) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStudentsSheet(batch: batch),
    );
  }

  @override
  ConsumerState<AddStudentsSheet> createState() => _AddStudentsSheetState();
}

class _AddStudentsSheetState extends ConsumerState<AddStudentsSheet> {
  String _searchQuery = '';
  final Set<int> _selectedStudentIds = {};
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final allStudentsAsync = ref.watch(studentListProvider);
    final batchStudentsAsync = ref.watch(batchStudentsProvider(widget.batch.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Students',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: NeumorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search students...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),

          // Students List
          Expanded(
            child: allStudentsAsync.when(
              loading: () => const Center(child: ListSkeleton(itemCount: 5)),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load students',
                onRetry: () => ref.invalidate(studentListProvider),
              ),
              data: (allStudents) {
                return batchStudentsAsync.when(
                  loading: () => const Center(child: ListSkeleton(itemCount: 5)),
                  error: (error, stack) => ErrorDisplay(
                    message: 'Failed to load batch students',
                    onRetry: () => ref.invalidate(batchStudentsProvider(widget.batch.id)),
                  ),
                  data: (batchStudents) {
                    // Get IDs of students already in the batch
                    final enrolledIds = batchStudents.map((s) => s.id).toSet();

                    // Filter out already enrolled students and apply search
                    final availableStudents = allStudents.where((student) {
                      if (enrolledIds.contains(student.id)) return false;
                      if (_searchQuery.isEmpty) return true;
                      return student.name.toLowerCase().contains(_searchQuery) ||
                          student.email.toLowerCase().contains(_searchQuery) ||
                          student.phone.contains(_searchQuery);
                    }).toList();

                    if (availableStudents.isEmpty) {
                      return const Center(
                        child: Text(
                          'No available students to add',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      itemCount: availableStudents.length,
                      itemBuilder: (context, index) {
                        final student = availableStudents[index];
                        final isSelected = _selectedStudentIds.contains(student.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                          child: NeumorphicContainer(
                            padding: const EdgeInsets.all(AppDimensions.paddingM),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedStudentIds.remove(student.id);
                                } else {
                                  _selectedStudentIds.add(student.id);
                                }
                              });
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedStudentIds.add(student.id);
                                      } else {
                                        _selectedStudentIds.remove(student.id);
                                      }
                                    });
                                  },
                                  activeColor: AppColors.accent,
                                ),
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (student.email.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          student.email,
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
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Add button
          if (_selectedStudentIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _addSelectedStudents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Add ${_selectedStudentIds.length} Student${_selectedStudentIds.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addSelectedStudents() async {
    setState(() => _isAdding = true);

    try {
      final batchNotifier = ref.read(batchListProvider.notifier);
      int successCount = 0;

      for (final studentId in _selectedStudentIds) {
        try {
          await batchNotifier.enrollStudent(widget.batch.id, studentId);
          successCount++;
        } catch (e) {
          // Continue with other students if one fails
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        SuccessSnackbar.show(
          context,
          '$successCount student${successCount > 1 ? 's' : ''} added to batch',
        );
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to add students: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }
}
