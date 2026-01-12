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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Student>>(
        future: ref.read(studentServiceProvider).getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingSpinner());
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              message: 'Failed to load students',
              onRetry: () => setState(() {}),
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
              return student.status != 'active';
            }
            return true;
          }).toList();

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
                  const Text(
                    'No students added yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
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
              ),
            );
          }

          return Column(
            children: [
              // Search and Filter
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
              // Students List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
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
                                child: const Row(
                                  children: [
                                    Icon(Icons.group_add, size: 18, color: AppColors.textPrimary),
                                    SizedBox(width: 8),
                                    Text('Assign Batch', style: TextStyle(color: AppColors.textPrimary)),
                                  ],
                                ),
                                onTap: () {
                                  Future.delayed(Duration.zero, () {
                                    _showAssignBatchDialog(context, student);
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
                        future: _getStudentBatchAndFeeStatus(student.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data!;
                            final batchName = data['batchName'] as String?;
                            final feeStatus = data['feeStatus'] as String?;
                            
                            return Column(
                              children: [
                                if (batchName != null) ...[
                                  _InfoRow(
                                    icon: Icons.group,
                                    label: 'Batch',
                                    value: batchName,
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
                ),
              ),
            ],
          );
        },
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
            setState(() {});
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showAssignBatchDialog(BuildContext context, Student student) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final batches = await batchService.getBatches();
      
      if (batches.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No batches available. Please create a batch first.')),
          );
        }
        return;
      }

      int? selectedBatchId;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Assign to Batch', style: TextStyle(color: AppColors.textPrimary)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<int>(
                value: selectedBatchId,
                decoration: const InputDecoration(
                  labelText: 'Select Batch',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                items: batches.map((batch) {
                  return DropdownMenuItem<int>(
                    value: batch.id,
                    child: Text(batch.batchName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedBatchId = value),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: selectedBatchId == null
                  ? null
                  : () async {
                      try {
                        await batchService.enrollStudent(selectedBatchId!, student.id);
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Student assigned to batch successfully')),
                          );
                          setState(() {});
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to assign batch: $e')),
                          );
                        }
                      }
                    },
              child: const Text('Assign'),
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

  Future<Map<String, dynamic>> _getStudentBatchAndFeeStatus(int studentId) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final feeService = ref.read(feeServiceProvider);
      
      // Get all batches and find which one contains this student
      final batches = await batchService.getBatches();
      String? batchName;
      for (final batch in batches) {
        try {
          final batchStudents = await batchService.getBatchStudents(batch.id);
          if (batchStudents.any((s) => s.id == studentId)) {
            batchName = batch.batchName;
            break;
          }
        } catch (e) {
          // Skip if batch students fetch fails
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
        'batchName': batchName,
        'feeStatus': feeStatus,
      };
    } catch (e) {
      return {};
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
