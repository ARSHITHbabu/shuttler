import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/service_providers.dart';
import '../../models/student.dart';
import '../../widgets/forms/add_student_dialog.dart';
import '../../widgets/forms/edit_student_dialog.dart';
import '../../models/batch.dart';
import '../../models/fee.dart';
import '../../core/services/batch_service.dart';
import '../../core/services/fee_service.dart';
import 'performance_tracking_screen.dart';
import 'bmi_tracking_screen.dart';
import 'fees_screen.dart';

/// Students List Screen - Shows all students with add button
class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'active', 'inactive'
  Future<List<Student>>? _studentsFuture;
  int _refreshKey = 0; // Key to force FutureBuilder rebuild

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStudents() {
    _studentsFuture = ref.read(studentServiceProvider).getStudents();
  }

  @override
  Widget build(BuildContext context) {
    // Load students on first build
    _studentsFuture ??= ref.read(studentServiceProvider).getStudents();
    
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
                    onChanged: (value) => setState(() {}),
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
          // Students List or Empty State - Inside FutureBuilder
          Expanded(
            child: FutureBuilder<List<Student>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingSpinner());
                }

                if (snapshot.hasError) {
                  return ErrorDisplay(
                    message: 'Failed to load students',
                    onRetry: () {
                      _loadStudents();
                      setState(() {});
                    },
                  );
                }

                final allStudents = snapshot.data ?? [];
                
                // Apply search filter
                final searchQuery = _searchController.text.toLowerCase();
                var filteredStudents = allStudents.where((student) {
                  if (searchQuery.isNotEmpty) {
                    final matchesSearch = student.name.toLowerCase().contains(searchQuery) ||
                        student.email.toLowerCase().contains(searchQuery) ||
                        student.phone.contains(searchQuery);
                    if (!matchesSearch) return false;
                  }
                  // Apply status filter
                  if (_selectedFilter == 'active') {
                    return student.status == 'active';
                  } else if (_selectedFilter == 'inactive') {
                    return student.status == 'inactive';
                  }
                  return true;
                }).toList();

                // Sort filtered students alphabetically by name
                filteredStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                // Determine empty message based on filter
                String emptyMessage;
                if (_selectedFilter == 'active') {
                  emptyMessage = 'No active students found';
                } else if (_selectedFilter == 'inactive') {
                  emptyMessage = 'No inactive students found';
                } else {
                  emptyMessage = 'No students added yet';
                }

                if (filteredStudents.isEmpty) {
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
                          emptyMessage,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        if (_selectedFilter == 'all') ...[
                          const SizedBox(height: AppDimensions.spacingL),
                          ElevatedButton.icon(
                            onPressed: () => _showAddStudentDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Student'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadStudents();
                    setState(() {});
                  },
                  child: ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                                  return NeumorphicContainer(
                              key: ValueKey('student_${student.id}_$_refreshKey'),
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
                                  // Batch and Fee Status (async loaded)
                                  FutureBuilder<Map<String, dynamic>>(
                                    key: ValueKey('batch_status_${student.id}_$_refreshKey'),
                                    future: _getStudentBatchAndFeeStatus(student.id, cacheBuster: _refreshKey),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final data = snapshot.data!;
                                        final batches = data['batches'] as List<Batch>? ?? [];
                                        final feeStatus = data['feeStatus'] as String?;
                                        
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
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
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
                                                builder: (context) => const PerformanceTrackingScreen(),
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
                                                builder: (context) => const BMITrackingScreen(),
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
                                                builder: (context) => const FeesScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddStudentDialog(
        onSubmit: (studentData) async {
          final studentService = ref.read(studentServiceProvider);
          await studentService.createStudent(studentData);
          if (mounted) {
            _loadStudents();
            setState(() {});
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
          final studentService = ref.read(studentServiceProvider);
          await studentService.updateStudent(student.id, studentData);
          if (mounted) {
            _loadStudents();
            setState(() {});
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showManageBatchesDialog(BuildContext context, Student student) async {
    // Capture widget's setState to avoid shadowing by StatefulBuilder
    final widgetSetState = setState;
    try {
      final batchService = ref.read(batchServiceProvider);
      final studentBatches = await batchService.getStudentBatches(student.id);
      
      if (studentBatches.isEmpty) {
        // No batches assigned, show simple assign dialog
        _showAddBatchDialog(context, student, []);
        return;
      }

      // Show manage batches dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                                  await batchService.removeStudent(batch.id, student.id);
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Student removed from batch successfully')),
                                    );
                                    // Increment refreshKey FIRST, then reload students
                                    // This ensures FutureBuilder gets the new key value
                                    // Use widget's setState, not dialog's setState
                                    widgetSetState(() {
                                      _refreshKey++; // Force FutureBuilder rebuild
                                      // Refresh the student list AFTER key increment
                                      _loadStudents();
                                    });
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    final errorMessage = e.toString().replaceFirst('Exception: ', '');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to remove from batch: $errorMessage'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
                          Navigator.of(context).pop();
                          await _showAddBatchDialog(context, student, studentBatches);
                          // Refresh after add dialog closes
                          if (mounted) {
                            widgetSetState(() {
                              _refreshKey++;
                              _loadStudents();
                            });
                          }
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
                            Navigator.of(context).pop();
                            await _showChangeBatchDialog(context, student, studentBatches.first);
                            // Refresh after change dialog closes
                            if (mounted) {
                              widgetSetState(() {
                                _refreshKey++;
                                _loadStudents();
                              });
                            }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load batches: $e')),
        );
      }
    }
  }

  Future<void> _showAddBatchDialog(BuildContext context, Student student, List<Batch> existingBatches) async {
    // Capture parent context before dialog (Fix: Use parent context for ScaffoldMessenger)
    final parentContext = context;
    // Capture widget's setState to avoid shadowing by StatefulBuilder
    final widgetSetState = setState;
    
    try {
      final batchService = ref.read(batchServiceProvider);
      final allBatches = await batchService.getBatches();
      
      if (allBatches.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(content: Text('No batches available. Please create a batch first.')),
          );
        }
        return;
      }

      // Filter out batches student is already in
      final existingBatchIds = existingBatches.map((b) => b.id).toSet();
      final availableBatches = allBatches.where((b) => !existingBatchIds.contains(b.id)).toList();

      if (availableBatches.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(content: Text('Student is already enrolled in all available batches.')),
          );
        }
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
                    value: selectedBatchId,
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
                            await batchService.enrollStudent(selectedBatchId!, student.id);
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              // Use parent context instead of dialog context (Fix)
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(content: Text('Student added to batch successfully')),
                              );
                              // Refresh is handled by the button handler that opened this dialog
                            }
                          } catch (e) {
                            if (mounted) {
                              final errorMessage = e.toString().replaceFirst('Exception: ', '');
                              // Use parent context instead of dialog context (Fix)
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add batch: $errorMessage'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
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
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text('Failed to load batches: $errorMessage'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showChangeBatchDialog(BuildContext context, Student student, Batch currentBatch) async {
    // Capture parent context before dialog (Fix: Use parent context for ScaffoldMessenger)
    final parentContext = context;
    // Capture widget's setState to avoid shadowing by StatefulBuilder
    final widgetSetState = setState;
    
    try {
      final batchService = ref.read(batchServiceProvider);
      final allBatches = await batchService.getBatches();
      
      if (allBatches.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(content: Text('No batches available. Please create a batch first.')),
          );
        }
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
                        value: selectedBatchId,
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
                            // Remove from current batch and add to new batch
                            await batchService.removeStudent(currentBatch.id, student.id);
                            await batchService.enrollStudent(selectedBatchId!, student.id);
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              // Use parent context instead of dialog context (Fix)
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(content: Text('Batch changed successfully')),
                              );
                              // Refresh is handled by the button handler that opened this dialog
                            }
                          } catch (e) {
                            if (mounted) {
                              final errorMessage = e.toString().replaceFirst('Exception: ', '');
                              // Use parent context instead of dialog context (Fix)
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to change batch: $errorMessage'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
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
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text('Failed to load batches: $errorMessage'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _getStudentBatchAndFeeStatus(int studentId, {int? cacheBuster}) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final feeService = ref.read(feeServiceProvider);
      
      // Get all batches for this student
      List<Batch> studentBatches = [];
      try {
        studentBatches = await batchService.getStudentBatches(studentId);
      } catch (e) {
        // Fallback: Get all batches and find which ones contain this student
        final batches = await batchService.getBatches();
        for (final batch in batches) {
          try {
            final batchStudents = await batchService.getBatchStudents(batch.id);
            if (batchStudents.any((s) => s.id == studentId)) {
              studentBatches.add(batch);
            }
          } catch (e) {
            // Skip if batch students fetch fails
          }
        }
      }
      
      // Get fee status
      String? feeStatus;
      try {
        final fees = await feeService.getFees(studentId: studentId);
        if (fees.isNotEmpty) {
          final pendingFees = fees.where((f) => f.status != 'paid').toList();
          if (pendingFees.isNotEmpty) {
            final overdueFees = pendingFees.where((f) => f.isOverdue).toList();
            feeStatus = overdueFees.isNotEmpty ? 'overdue' : 'pending';
          } else {
            feeStatus = 'paid';
          }
        }
      } catch (e) {
        // Skip if fees fetch fails
      }
      
      return {
        'batches': studentBatches,
        'feeStatus': feeStatus,
      };
    } catch (e) {
      return {'batches': <Batch>[]};
    }
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

  void _toggleStudentStatus(BuildContext context, Student student) async {
    try {
      final studentService = ref.read(studentServiceProvider);
      final newStatus = student.status == 'active' ? 'inactive' : 'active';
      await studentService.updateStudent(student.id, {'status': newStatus});
      if (mounted) {
        _loadStudents();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update student status: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Student', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete ${student.name}? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final studentService = ref.read(studentServiceProvider);
                await studentService.deleteStudent(student.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadStudents();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete student: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
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
