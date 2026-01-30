import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/service_providers.dart';
import '../../providers/student_provider.dart';
import '../../models/student.dart';
import '../../widgets/forms/add_student_dialog.dart';
import '../../widgets/forms/edit_student_dialog.dart';
import '../../models/batch.dart';
import '../../core/services/fee_service.dart';
import '../../core/services/batch_enrollment_service.dart';
import '../../providers/batch_provider.dart';
import 'performance_tracking_screen.dart';
import 'bmi_tracking_screen.dart';
import 'fees_screen.dart';
import '../../widgets/dialogs/student_details_dialog.dart';

/// Students List Screen - Shows all students with add button
class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'active', 'inactive'
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use provider for student list with search
    final studentsAsync = _searchQuery.isEmpty
        ? ref.watch(studentListProvider)
        : ref.watch(studentSearchProvider(_searchQuery));
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Students',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: () => _showAddStudentDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter - Always visible, outside FutureBuilder
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                // Search Bar
                NeumorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Search students...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: AppColors.textSecondary),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedFilter == 'all',
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      _FilterChip(
                        label: 'Active',
                        isSelected: _selectedFilter == 'active',
                        onTap: () => setState(() => _selectedFilter = 'active'),
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      _FilterChip(
                        label: 'Inactive',
                        isSelected: _selectedFilter == 'inactive',
                        onTap: () => setState(() => _selectedFilter = 'inactive'),
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Students List or Empty State - Using Provider
          Expanded(
            child: studentsAsync.when(
              loading: () => const ListSkeleton(itemCount: 5),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load students: ${error.toString()}',
                onRetry: () => ref.invalidate(studentListProvider),
              ),
              data: (allStudents) {
                // Apply status filter - exclude rejected students from the list completely
                var filteredStudents = allStudents.where((student) {
                  // Always exclude rejected students - they should not appear in the list
                  if (student.status == 'rejected') {
                    return false;
                  }
                  
                  if (_selectedFilter == 'active') {
                    return student.status == 'active';
                  } else if (_selectedFilter == 'inactive') {
                    return student.status == 'inactive';
                  }
                  // For 'all' filter, show all except rejected
                  return true;
                }).toList();

                // Sort filtered students alphabetically by name
                filteredStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                if (filteredStudents.isEmpty) {
                  if (_selectedFilter == 'all' && _searchQuery.isEmpty) {
                    return EmptyState.noStudents(
                      onAdd: () => _showAddStudentDialog(context),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          Text(
                            _selectedFilter == 'active'
                                ? 'No active students found'
                                : _selectedFilter == 'inactive'
                                    ? 'No inactive students found'
                                    : 'No students found',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(studentListProvider);
                    if (_searchQuery.isNotEmpty) {
                      ref.invalidate(studentSearchProvider(_searchQuery));
                    }
                    return;
                  },
                  child: ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                                  return InkWell(
                              onTap: () => _showStudentDetailsDialog(context, student),
                              child: NeumorphicContainer(
                              key: ValueKey('student_${student.id}'),
                              padding: const EdgeInsets.all(AppDimensions.paddingM),
                              margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          student.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDimensions.spacingM,
                                          vertical: AppDimensions.spacingS,
                                        ),
                                        decoration: BoxDecoration(
                                          color: student.status == 'active'
                                              ? AppColors.success
                                              : AppColors.error,
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                        ),
                                        child: Text(
                                          student.status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton(
                                        icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                                        color: AppColors.cardBackground,
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.edit, size: 18, color: AppColors.textPrimary),
                                                SizedBox(width: 8),
                                                Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                                              ],
                                            ),
                                            onTap: () {
                                              Future.delayed(Duration.zero, () {
                                                _showEditStudentDialog(context, student);
                                              });
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  student.status == 'active' 
                                                      ? Icons.person_off 
                                                      : Icons.person,
                                                  size: 18,
                                                  color: student.status == 'active' 
                                                      ? AppColors.error 
                                                      : AppColors.success,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  student.status == 'active' 
                                                      ? 'Mark Inactive' 
                                                      : 'Mark Active',
                                                  style: TextStyle(
                                                    color: student.status == 'active' 
                                                        ? AppColors.error 
                                                        : AppColors.success,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Future.delayed(Duration.zero, () {
                                                _toggleStudentStatus(context, student);
                                              });
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.group_add, size: 18, color: AppColors.textPrimary),
                                                SizedBox(width: 8),
                                                Text('Manage Batches', style: TextStyle(color: AppColors.textPrimary)),
                                              ],
                                            ),
                                            onTap: () {
                                              Future.delayed(Duration.zero, () {
                                                _showManageBatchesDialog(context, student);
                                              });
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.delete, size: 18, color: AppColors.error),
                                                SizedBox(width: 8),
                                                Text('Delete', style: TextStyle(color: AppColors.error)),
                                              ],
                                            ),
                                            onTap: () {
                                              Future.delayed(Duration.zero, () {
                                                _showDeleteConfirmation(context, student);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppDimensions.spacingM),
                                  // Batch and Fee Status (using providers)
                                  _StudentBatchAndFeeStatus(studentId: student.id),
                                  if (student.email.isNotEmpty) ...[
                                    const SizedBox(height: AppDimensions.spacingS),
                                    _InfoRow(
                                      icon: Icons.email_outlined,
                                      label: 'Email',
                                      value: student.email,
                                    ),
                                  ],
                                  if (student.phone.isNotEmpty) ...[
                                    const SizedBox(height: AppDimensions.spacingS),
                                    _InfoRow(
                                      icon: Icons.phone_outlined,
                                      label: 'Phone',
                                      value: student.phone,
                                    ),
                                  ],
                                  if (student.guardianName != null && student.guardianName!.isNotEmpty) ...[
                                    const SizedBox(height: AppDimensions.spacingS),
                                    _InfoRow(
                                      icon: Icons.person_outline,
                                      label: 'Guardian',
                                      value: student.guardianName!,
                                    ),
                                  ],
                                  if (student.guardianPhone != null && student.guardianPhone!.isNotEmpty) ...[
                                    const SizedBox(height: AppDimensions.spacingS),
                                    _InfoRow(
                                      icon: Icons.phone_outlined,
                                      label: 'Guardian Phone',
                                      value: student.guardianPhone!,
                                    ),
                                  ],
                                  const SizedBox(height: AppDimensions.spacingM),
                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ActionButton(
                                          icon: Icons.trending_up,
                                          label: 'Performance',
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => PerformanceTrackingScreen(
                                                  initialStudent: student,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppDimensions.spacingS),
                                      Expanded(
                                        child: _ActionButton(
                                          icon: Icons.monitor_weight,
                                          label: 'BMI',
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => BMITrackingScreen(
                                                  initialStudent: student,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppDimensions.spacingS),
                                      Expanded(
                                        child: _ActionButton(
                                          icon: Icons.attach_money,
                                          label: 'Fees',
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => FeesScreen(
                                                  selectedStudentId: student.id,
                                                  selectedStudentName: student.name,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                          },
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetailsDialog(BuildContext context, Student student) {
    StudentDetailsDialog.show(context, student);
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddStudentDialog(
        onSubmit: (studentData) async {
          try {
            await ref.read(studentListProvider.notifier).createStudent(studentData);
            if (mounted) {
              Navigator.of(context).pop();
              SuccessSnackbar.show(context, 'Student added successfully');
            }
          } catch (e) {
            if (mounted) {
              SuccessSnackbar.showError(context, 'Failed to add student: ${e.toString()}');
            }
          }
        },
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => EditStudentDialog(
        student: student,
        onSubmit: (studentData) async {
          try {
            await ref.read(studentListProvider.notifier).updateStudent(student.id, studentData);
            if (mounted) {
              Navigator.of(context).pop();
              SuccessSnackbar.show(context, 'Student updated successfully');
            }
          } catch (e) {
            if (mounted) {
              SuccessSnackbar.showError(context, 'Failed to update student: ${e.toString()}');
            }
          }
        },
      ),
    );
  }

  void _showManageBatchesDialog(BuildContext context, Student student) async {
    try {
      // Use provider to get student batches reactively
      // Use .future to get the Future from the AsyncValue
      final studentBatches = await ref.read(studentBatchesProvider(student.id).future);
      
      if (studentBatches.isEmpty) {
        // No batches assigned, show simple assign dialog
        _showAddBatchDialog(context, student, []);
        return;
      }

      // Show manage batches dialog
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
                    ...studentBatches.map((batch) {
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
                                  await BatchEnrollmentHelper.removeStudent(ref, batch.id, student.id);
                                  if (mounted && Navigator.of(dialogContext).canPop()) {
                                    Navigator.of(dialogContext).pop();
                                    SuccessSnackbar.show(context, 'Student removed from batch successfully');
                                    // No need to manually refresh - providers handle it automatically
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
                    const Text(
                      'Actions:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await _showAddBatchDialog(context, student, studentBatches);
                          // No need to manually refresh - providers handle it automatically
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Another Batch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    if (studentBatches.length == 1) ...[
                      const SizedBox(height: AppDimensions.spacingS),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await _showChangeBatchDialog(context, student, studentBatches.first);
                            // No need to manually refresh - providers handle it automatically
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Change Batch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardBackground,
                            foregroundColor: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
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

  Future<void> _showAddBatchDialog(BuildContext context, Student student, List<Batch> existingBatches) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final allBatches = await batchService.getBatches();
      
      if (allBatches.isEmpty) {
        SuccessSnackbar.showInfo(context, 'No batches available. Please create a batch first.');
        return;
      }

      // Filter out batches student is already in
      final existingBatchIds = existingBatches.map((b) => b.id).toSet();
      final availableBatches = allBatches.where((b) => !existingBatchIds.contains(b.id)).toList();

      if (availableBatches.isEmpty) {
        SuccessSnackbar.showInfo(context, 'Student is already enrolled in all available batches.');
        return;
      }

      // Use ValueNotifier to properly manage state
      final selectedBatchIdNotifier = ValueNotifier<int?>(null);
      
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Add Another Batch', style: TextStyle(color: AppColors.textPrimary)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return ValueListenableBuilder<int?>(
                valueListenable: selectedBatchIdNotifier,
                builder: (context, selectedBatchId, _) {
                  return DropdownButtonFormField<int>(
                    initialValue: selectedBatchId,
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
                            await BatchEnrollmentHelper.enrollStudent(ref, selectedBatchId, student.id);
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              SuccessSnackbar.show(context, 'Student added to batch successfully');
                              // Providers automatically update all UI components
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

  Future<void> _showChangeBatchDialog(BuildContext context, Student student, Batch currentBatch) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final allBatches = await batchService.getBatches();
      
      if (allBatches.isEmpty) {
        SuccessSnackbar.showInfo(context, 'No batches available. Please create a batch first.');
        return;
      }

      // Use ValueNotifier to properly manage state - initialize to null (Fix 3)
      final selectedBatchIdNotifier = ValueNotifier<int?>(null);
      
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Change Batch', style: TextStyle(color: AppColors.textPrimary)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return ValueListenableBuilder<int?>(
                valueListenable: selectedBatchIdNotifier,
                builder: (context, selectedBatchId, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current: ${currentBatch.batchName}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      DropdownButtonFormField<int>(
                        initialValue: selectedBatchId,
                        decoration: const InputDecoration(
                          labelText: 'Select New Batch',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                        dropdownColor: AppColors.cardBackground,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: allBatches.map((batch) {
                          return DropdownMenuItem<int>(
                            value: batch.id,
                            child: Text(batch.batchName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedBatchIdNotifier.value = value;
                        },
                      ),
                    ],
                  );
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
                  onPressed: selectedBatchId == null || selectedBatchId == currentBatch.id
                      ? null
                      : () async {
                          try {
                            // Transfer student from current batch to new batch
                            await BatchEnrollmentHelper.transferStudent(
                              ref,
                              currentBatch.id,
                              selectedBatchId,
                              student.id,
                            );
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              SuccessSnackbar.show(context, 'Batch changed successfully');
                              // Providers automatically update all UI components
                            }
                          } catch (e) {
                            final errorMessage = e.toString().replaceFirst('Exception: ', '');
                            SuccessSnackbar.showError(context, 'Failed to change batch: $errorMessage');
                          }
                        },
                  child: const Text('Change'),
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


  void _toggleStudentStatus(BuildContext context, Student student) async {
    try {
      final newStatus = student.status == 'active' ? 'inactive' : 'active';
      await ref.read(studentListProvider.notifier).updateStudent(student.id, {'status': newStatus});
      if (mounted) {
        SuccessSnackbar.show(context, 'Student ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully');
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to update student status: ${e.toString()}');
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, Student student) {
    ConfirmationDialog.showDelete(
      context,
      student.name,
      onConfirm: () async {
        try {
          await ref.read(studentListProvider.notifier).deleteStudent(student.id);
          if (mounted) {
            SuccessSnackbar.show(context, 'Student deleted successfully');
          }
        } catch (e) {
          if (mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete student: ${e.toString()}');
          }
        }
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.accent).withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: isSelected ? (color ?? AppColors.accent) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? (color ?? AppColors.accent) : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
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
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget that displays student batches and fee status using providers
class _StudentBatchAndFeeStatus extends ConsumerWidget {
  final int studentId;

  const _StudentBatchAndFeeStatus({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentBatchesAsync = ref.watch(studentBatchesProvider(studentId));
    final feeService = ref.watch(feeServiceProvider);

    return FutureBuilder<String?>(
      future: _getFeeStatus(feeService, studentId),
      builder: (context, feeSnapshot) {
        return studentBatchesAsync.when(
          data: (batches) {
            final feeStatus = feeSnapshot.data;
            return Column(
              children: [
                if (batches.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.group, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Wrap(
                          spacing: AppDimensions.spacingS,
                          runSpacing: AppDimensions.spacingS,
                          children: batches.map((batch) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingS,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                batch.batchName,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                ],
                if (feeStatus != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingS),
                      const Text(
                        'Fee Status: ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getFeeStatusColor(feeStatus),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: Text(
                          feeStatus.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                ],
              ],
            );
          },
          loading: () => SizedBox(
            height: 20,
            child: Center(
              child: Shimmer.fromColors(
                baseColor: AppColors.cardBackground,
                highlightColor: AppColors.surfaceLight,
                period: const Duration(milliseconds: 1200),
                child: Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
              ),
            ),
          ),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Future<String?> _getFeeStatus(FeeService feeService, int studentId) async {
    try {
      final fees = await feeService.getFees(studentId: studentId);
      if (fees.isNotEmpty) {
        final pendingFees = fees.where((f) => f.status != 'paid').toList();
        if (pendingFees.isNotEmpty) {
          final overdueFees = pendingFees.where((f) => f.isOverdue).toList();
          return overdueFees.isNotEmpty ? 'overdue' : 'pending';
        } else {
          return 'paid';
        }
      }
    } catch (e) {
      // Skip if fees fetch fails
    }
    return null;
  }

  Color _getFeeStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'overdue':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingS,
          horizontal: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
