import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../models/student.dart';

/// Coach Attendance Screen - Mark attendance for assigned batches
class CoachAttendanceScreen extends ConsumerStatefulWidget {
  const CoachAttendanceScreen({super.key});

  @override
  ConsumerState<CoachAttendanceScreen> createState() => _CoachAttendanceScreenState();
}

class _CoachAttendanceScreenState extends ConsumerState<CoachAttendanceScreen> {
  int? _selectedBatchId;
  DateTime _selectedDate = DateTime.now();
  final Map<int, String> _attendance = {}; // studentId -> 'present' or 'absent'
  final Map<int, String> _remarks = {}; // studentId -> remarks
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load existing attendance when batch/date changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedBatchId != null) {
        _loadExistingAttendance();
      }
    });
  }

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
      loading: () => const Center(child: LoadingSpinner()),
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Mark Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Date Picker
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.iconPrimary,
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                          _attendance.clear();
                          _remarks.clear();
                        });
                        if (_selectedBatchId != null) {
                          _loadExistingAttendance();
                        }
                      }
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Batch Selector
            batchesAsync.when(
              data: (batches) {
                if (batches.isEmpty) {
                  return NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: const Center(
                      child: Text(
                        'No batches assigned to you yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Batch',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      DropdownButtonFormField<int>(
                        value: _selectedBatchId,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        ),
                        hint: const Text('Choose a batch'),
                        items: batches.map((batch) {
                          return DropdownMenuItem<int>(
                            value: batch.id,
                            child: Text('${batch.batchName} - ${batch.timing}'),
                          );
                        }).toList(),
                        onChanged: (batchId) {
                          setState(() {
                            _selectedBatchId = batchId;
                            _attendance.clear();
                            _remarks.clear();
                          });
                          if (batchId != null) {
                            _loadExistingAttendance();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: LoadingSpinner()),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load batches',
                onRetry: () => ref.invalidate(coachBatchesProvider(coachId)),
              ),
            ),

            if (_selectedBatchId != null) ...[
              const SizedBox(height: AppDimensions.spacingL),
              _buildStudentsList(),
            ],

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    final batchService = ref.watch(batchServiceProvider);
    final studentsFuture = batchService.getBatchStudents(_selectedBatchId!);

    return FutureBuilder<List<Student>>(
      future: studentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingSpinner());
        }

        if (snapshot.hasError) {
          return ErrorDisplay(
            message: 'Failed to load students',
            onRetry: () {
              setState(() {});
            },
          );
        }

        final students = snapshot.data ?? [];
        if (students.isEmpty) {
          return NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: const Center(
              child: Text(
                'No students enrolled in this batch',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return _buildStudentsContent(students);
      },
    );
  }

  Widget _buildStudentsContent(List<Student> students) {
    final presentCount = _attendance.values.where((v) => v == 'present').length;
    final absentCount = _attendance.values.where((v) => v == 'absent').length;
    final totalMarked = _attendance.length;
    final totalStudents = students.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Present',
                value: presentCount.toString(),
                color: AppColors.success,
              ),
              _SummaryItem(
                label: 'Absent',
                value: absentCount.toString(),
                color: AppColors.error,
              ),
              _SummaryItem(
                label: 'Marked',
                value: '$totalMarked/$totalStudents',
                color: AppColors.accent,
              ),
              _SummaryItem(
                label: 'Percentage',
                value: totalStudents > 0
                    ? '${((presentCount / totalStudents) * 100).toStringAsFixed(0)}%'
                    : '0%',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Students List
        ...students.map((student) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
            child: _StudentAttendanceCard(
              student: student,
              status: _attendance[student.id],
              remarks: _remarks[student.id] ?? '',
              onStatusChanged: (status) {
                setState(() {
                  if (status == null) {
                    _attendance.remove(student.id);
                    _remarks.remove(student.id);
                  } else {
                    _attendance[student.id] = status;
                  }
                });
              },
              onRemarksChanged: (remarks) {
                setState(() {
                  if (remarks.isEmpty) {
                    _remarks.remove(student.id);
                  } else {
                    _remarks[student.id] = remarks;
                  }
                });
              },
            ),
          );
        }),

        const SizedBox(height: AppDimensions.spacingL),

        // Save Button
        NeumorphicButton(
          text: _isSaving ? 'Saving...' : 'Save Attendance',
          onPressed: _isSaving || _attendance.isEmpty ? null : _saveAttendance,
          icon: _isSaving ? null : Icons.save_outlined,
          isAccent: true,
        ),
      ],
    );
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedBatchId == null) return;

    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      final existingAttendance = await attendanceService.getAttendance(
        date: _selectedDate,
        batchId: _selectedBatchId!,
      );

      if (mounted) {
        setState(() {
          _attendance.clear();
          _remarks.clear();
          for (final record in existingAttendance) {
            _attendance[record.studentId] = record.status.toLowerCase();
            if (record.remarks != null && record.remarks!.isNotEmpty) {
              _remarks[record.studentId] = record.remarks!;
            }
          }
        });
      }
    } catch (e) {
      // Silently fail - user can mark attendance fresh
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a batch'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      final batchService = ref.read(batchServiceProvider);
      final students = await batchService.getBatchStudents(_selectedBatchId!);

      // Mark attendance for all students (present, absent, or skip if not marked)
      for (final student in students) {
        final status = _attendance[student.id];
        if (status != null) {
          await attendanceService.markStudentAttendance(
            studentId: student.id,
            batchId: _selectedBatchId!,
            date: _selectedDate,
            status: status,
            remarks: _remarks[student.id],
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save attendance: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StudentAttendanceCard extends StatefulWidget {
  final Student student;
  final String? status;
  final String remarks;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String> onRemarksChanged;

  const _StudentAttendanceCard({
    required this.student,
    required this.status,
    required this.remarks,
    required this.onStatusChanged,
    required this.onRemarksChanged,
  });

  @override
  State<_StudentAttendanceCard> createState() => _StudentAttendanceCardState();
}

class _StudentAttendanceCardState extends State<_StudentAttendanceCard> {
  late TextEditingController _remarksController;
  bool _showRemarks = false;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(text: widget.remarks);
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.background,
                child: Text(
                  widget.student.name.isNotEmpty
                      ? widget.student.name[0].toUpperCase()
                      : '?',
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
                      widget.student.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                                  if (widget.student.phone != null && widget.student.phone!.isNotEmpty)
                                    Text(
                                      widget.student.phone!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Status Buttons
              Row(
                children: [
                  _StatusButton(
                    label: 'Present',
                    isActive: widget.status == 'present',
                    color: AppColors.success,
                    onTap: () {
                      widget.onStatusChanged(widget.status == 'present' ? null : 'present');
                    },
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _StatusButton(
                    label: 'Absent',
                    isActive: widget.status == 'absent',
                    color: AppColors.error,
                    onTap: () {
                      widget.onStatusChanged(widget.status == 'absent' ? null : 'absent');
                    },
                  ),
                ],
              ),
            ],
          ),
          // Remarks Toggle
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showRemarks = !_showRemarks;
              });
            },
            icon: Icon(
              _showRemarks ? Icons.expand_less : Icons.expand_more,
              size: 16,
            ),
            label: const Text('Add Remarks'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
          // Remarks Field
          if (_showRemarks)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingS),
              child: TextField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  hintText: 'Enter remarks (optional)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(AppDimensions.paddingS),
                ),
                maxLines: 2,
                onChanged: (value) {
                  widget.onRemarksChanged(value);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          border: Border.all(
            color: isActive ? color : AppColors.textTertiary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
