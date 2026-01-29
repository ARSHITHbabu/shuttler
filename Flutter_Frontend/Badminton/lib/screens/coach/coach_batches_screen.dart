import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/batch_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/batch.dart';
import '../../models/student.dart';

/// Coach Batches Screen - View assigned batches (READ-ONLY)
class CoachBatchesScreen extends ConsumerStatefulWidget {
  const CoachBatchesScreen({super.key});

  @override
  ConsumerState<CoachBatchesScreen> createState() => _CoachBatchesScreenState();
}

class _CoachBatchesScreenState extends ConsumerState<CoachBatchesScreen> {
  String _searchQuery = '';
  int? _expandedBatchId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return const Center(
            child: Text(
              'Please login',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        final coachId = authValue.userId;
        return _buildContent(coachId);
      },
      loading: () => const Center(child: DashboardSkeleton()),
      error: (error, stack) => Center(
        child: Text(
          'Error: ${error.toString()}',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(int coachId) {
    final batchesAsync = ref.watch(coachBatchesProvider(coachId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(coachBatchesProvider(coachId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'My Batches',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Search Bar
              NeumorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search batches...',
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

              const SizedBox(height: AppDimensions.spacingL),

              // Batches List
              batchesAsync.when(
                data: (batches) {
                  if (batches.isEmpty) {
                    return NeumorphicContainer(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: const Center(
                        child: Text(
                          'No batches assigned yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  // Filter batches by search query
                  final filteredBatches = batches.where((batch) {
                    if (_searchQuery.isEmpty) return true;
                    return batch.batchName.toLowerCase().contains(_searchQuery) ||
                           batch.timing.toLowerCase().contains(_searchQuery) ||
                           (batch.location?.toLowerCase().contains(_searchQuery) ?? false);
                  }).toList();

                  return Column(
                    children: filteredBatches.map((batch) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                        child: _BatchCard(
                          batch: batch,
                          currentCoachId: coachId,
                          isExpanded: _expandedBatchId == batch.id,
                          onTap: () {
                            setState(() {
                              _expandedBatchId = _expandedBatchId == batch.id ? null : batch.id;
                            });
                          },
                          onViewStudents: () {
                            _showBatchStudents(context, batch);
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: ListSkeleton(itemCount: 3)),
                error: (error, stack) => ErrorDisplay(
                  message: 'Failed to load batches',
                  onRetry: () => ref.invalidate(coachBatchesProvider(coachId)),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  void _showBatchStudents(BuildContext context, Batch batch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BatchStudentsSheet(batch: batch),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  final int currentCoachId;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onViewStudents;

  const _BatchCard({
    required this.batch,
    required this.currentCoachId,
    required this.isExpanded,
    required this.onTap,
    required this.onViewStudents,
  });

  /// Format coach names with "me" indicator for current coach
  String _formatCoachNames() {
    if (batch.assignedCoaches.isEmpty) {
      // Fallback to old single coach field
      if (batch.assignedCoachName != null && batch.assignedCoachName!.isNotEmpty) {
        if (batch.assignedCoachId == currentCoachId) {
          return 'me';
        }
        return batch.assignedCoachName!;
      }
      return 'No coaches assigned';
    }

    final names = batch.assignedCoaches.map((coach) {
      if (coach.id == currentCoachId) {
        return 'me';
      }
      return coach.name;
    }).toList();

    // Sort to put "me" first
    names.sort((a, b) {
      if (a == 'me') return -1;
      if (b == 'me') return 1;
      return a.compareTo(b);
    });

    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.batchName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          batch.timing,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textSecondary,
              ),
            ],
          ),

          if (isExpanded) ...[
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(),
            const SizedBox(height: AppDimensions.spacingM),
            _InfoRow(
              icon: Icons.sports,
              label: 'Coaches',
              value: _formatCoachNames(),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Days',
              value: batch.period,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            if (batch.location != null)
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: batch.location!,
              ),
            if (batch.location != null)
              const SizedBox(height: AppDimensions.spacingS),
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Capacity',
              value: '${batch.capacity} students',
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _InfoRow(
              icon: Icons.attach_money,
              label: 'Fees',
              value: '\$${batch.fees}',
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SizedBox(
              width: double.infinity,
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                onTap: onViewStudents,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 20,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: AppDimensions.spacingS),
                    Text(
                      'View Students',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BatchStudentsSheet extends ConsumerStatefulWidget {
  final Batch batch;

  const _BatchStudentsSheet({required this.batch});

  @override
  ConsumerState<_BatchStudentsSheet> createState() => _BatchStudentsSheetState();
}

class _BatchStudentsSheetState extends ConsumerState<_BatchStudentsSheet> {
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
                      onPressed: () => _showAddStudentsDialog(context),
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
                onPressed: () => _showAddStudentsDialog(context),
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

  void _showAddStudentsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddStudentsSheet(batch: widget.batch),
    );
  }
}

/// Sheet for adding students to a batch
class _AddStudentsSheet extends ConsumerStatefulWidget {
  final Batch batch;

  const _AddStudentsSheet({required this.batch});

  @override
  ConsumerState<_AddStudentsSheet> createState() => _AddStudentsSheetState();
}

class _AddStudentsSheetState extends ConsumerState<_AddStudentsSheet> {
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
