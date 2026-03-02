import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/batch_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/service_providers.dart';
import '../../models/batch.dart';
import '../../models/attendance.dart';

/// Attendance Screen - Dual-mode attendance marking
/// Matches React reference: AttendanceScreen.tsx
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String _attendanceType = 'students'; // 'students' or 'coaches'
  int? _selectedBatchId;
  DateTime _selectedDate = DateTime.now();
  final Map<int, String> _attendance = {}; // studentId/coachId -> 'present' or 'absent'
  final Map<int, String> _remarks = {}; // studentId/coachId -> remarks
  bool _hasUnsavedChanges = false; // Track if there are unsaved changes

  bool get isSmallScreen => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Attendance Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: canPop ? 0 : AppDimensions.paddingL,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.paddingL),

            // Type Selector
            NeumorphicContainer(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeSelectorButton(
                      label: isSmallScreen ? 'Students' : 'Student Attendance',
                      icon: Icons.people_outline,
                      isActive: _attendanceType == 'students',
                      onTap: () {
                        setState(() {
                          _attendanceType = 'students';
                          _selectedBatchId = null;
                          _attendance.clear();
                          _remarks.clear();
                          _hasUnsavedChanges = false;
                        });
                        ref.invalidate(batchStudentsForAttendanceProvider);
                        // Note: Attendance will load when batch is selected
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TypeSelectorButton(
                      label: isSmallScreen ? 'Coaches' : 'Coach Attendance',
                      icon: Icons.person_outline,
                      isActive: _attendanceType == 'coaches',
                      onTap: () {
                        setState(() {
                          _attendanceType = 'coaches';
                          _selectedBatchId = null;
                          _attendance.clear();
                          _remarks.clear();
                          _hasUnsavedChanges = false;
                        });
                        ref.invalidate(coachesForAttendanceProvider);
                        // Load existing coach attendance for current date
                        _loadExistingCoachAttendance();
                      },
                    ),
                  ),
                ],
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
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.accent,
                                  surface: AppColors.cardBackground,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                          // Load existing attendance for the selected date
                          if (_attendanceType == 'students' && _selectedBatchId != null) {
                            _loadExistingAttendance();
                          } else if (_attendanceType == 'coaches') {
                            _loadExistingCoachAttendance();
                          }
                        }
                      },
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Batch Selector (for students)
            if (_attendanceType == 'students') ...[
              if (_selectedBatchId == null)
                _buildBatchSelector()
              else
                _buildStudentAttendanceList(),
            ],

            // Coach Summary Metrics (at top, before coach list)
            if (_attendanceType == 'coaches') ...[
              _buildCoachSummaryMetrics(),
              const SizedBox(height: AppDimensions.spacingL),
              // Coach List (for coaches)
              _buildCoachAttendanceList(),
              // Save and Cancel Buttons (only show when there are unsaved changes)
              if (_hasUnsavedChanges) ...[
                const SizedBox(height: AppDimensions.spacingL),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _attendance.isEmpty
                            ? null
                            : () => _saveAttendance(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, isSmallScreen ? 40 : 48),
                        ),
                        child: Text(isSmallScreen ? 'Save' : 'Save Attendance'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _attendance.isEmpty
                            ? null
                            : () => _cancelAttendance(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.textSecondary),
                          minimumSize: Size(double.infinity, isSmallScreen ? 40 : 48),
                        ),
                        child: Text(isSmallScreen ? 'Cancel' : 'Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildBatchSelector() {
    final batchesAsync = ref.watch(batchListProvider);

    return batchesAsync.when(
      data: (batches) {
        if (batches.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            child: Text(
              'No batches available',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return Column(
          children: batches.map((batch) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  onTap: () {
                        setState(() {
                          _selectedBatchId = batch.id;
                          _attendance.clear();
                          _remarks.clear();
                          _hasUnsavedChanges = false;
                        });
                        // Load existing attendance for selected batch and date
                        _loadExistingAttendance();
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batch.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              batch.timeRange,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              )).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: ListSkeleton(itemCount: 3),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: ErrorDisplay(
          message: 'Failed to load batches. Please check your connection and try again.',
          onRetry: () => ref.read(batchListProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceList() {
    if (_selectedBatchId == null) return const SizedBox.shrink();

    final studentsAsync = ref.watch(
      batchStudentsForAttendanceProvider(_selectedBatchId!),
    );
    final batchesAsync = ref.watch(batchListProvider);

    return studentsAsync.when(
      data: (students) {
        final batch = batchesAsync.value?.firstWhere(
          (b) => b.id == _selectedBatchId,
          orElse: () => Batch(
            id: _selectedBatchId!,
            batchName: 'Unknown',
            timing: '',
            period: '',
            capacity: 0,
            fees: '0',
            startDate: DateTime.now().toIso8601String().split('T')[0],
            createdBy: '',
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Header with Back Button
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.spacingS,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedBatchId = null;
                        _attendance.clear();
                        _remarks.clear();
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch?.name ?? 'Unknown Batch',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (batch?.timeRange != null)
                          Text(
                            batch!.timeRange,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            // Summary Metrics (at top, inside batch list for students)
            _buildSummaryMetrics(totalCount: students.length),
            const SizedBox(height: AppDimensions.spacingL),
            // Attendance List Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: Text(
                'Mark Attendance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            if (students.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppDimensions.paddingM),
                child: Text(
                  'No students enrolled in this batch',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...students.map((student) {
                    final attendanceStatus = _attendance[student.id];
                    return _AttendanceItem(
                      name: student.name,
                      isPresent: attendanceStatus == 'present',
                      hasSelection: attendanceStatus != null,
                      remark: _remarks[student.id] ?? '',
                      onPresentChanged: (isPresent) {
                        setState(() {
                          if (isPresent) {
                            _attendance[student.id] = 'present';
                          } else {
                            _attendance[student.id] = 'absent';
                          }
                          _hasUnsavedChanges = true;
                        });
                      },
                      onRemarkChanged: (remark) {
                        setState(() {
                          _remarks[student.id] = remark;
                          _hasUnsavedChanges = true;
                        });
                      },
                    );
                  }),
            // Save and Cancel Buttons (only show when there are unsaved changes)
            if (_hasUnsavedChanges) ...[
              const SizedBox(height: AppDimensions.spacingL),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _attendance.isEmpty
                          ? null
                          : () => _saveAttendance(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, isSmallScreen ? 40 : 48),
                      ),
                      child: Text(isSmallScreen ? 'Save' : 'Save Attendance'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _attendance.isEmpty
                          ? null
                          : () => _cancelAttendance(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.textSecondary),
                        minimumSize: Size(double.infinity, isSmallScreen ? 40 : 48),
                      ),
                      child: Text(isSmallScreen ? 'Cancel' : 'Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: ListSkeleton(itemCount: 3),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: ErrorDisplay(
          message: 'Failed to load students',
          onRetry: () => ref.invalidate(batchStudentsForAttendanceProvider(_selectedBatchId!)),
        ),
      ),
    );
  }

  Widget _buildSummaryMetrics({required int totalCount}) {
    final presentCount = _attendance.values.where((v) => v == 'present').length;
    final absentCount = _attendance.values.where((v) => v == 'absent').length;
    final percentage = totalCount > 0 
        ? ((presentCount / totalCount) * 100).toStringAsFixed(0)
        : '0';

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total',
            value: totalCount.toString(),
            color: AppColors.textSecondary,
          ),
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
          if (totalCount > 0)
            _SummaryItem(
              label: 'Percentage',
              value: '$percentage%',
              color: AppColors.iconPrimary,
            ),
        ],
      ),
    );
  }

  Widget _buildCoachSummaryMetrics() {
    final coachesAsync = ref.watch(coachesForAttendanceProvider);
    
    return coachesAsync.when(
      data: (coaches) => _buildSummaryMetrics(totalCount: coaches.length),
      loading: () => NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: 'Total',
              value: '...',
              color: AppColors.textSecondary,
            ),
            _SummaryItem(
              label: 'Present',
              value: '...',
              color: AppColors.success,
            ),
            _SummaryItem(
              label: 'Absent',
              value: '...',
              color: AppColors.error,
            ),
          ],
        ),
      ),
      error: (_, __) => _buildSummaryMetrics(totalCount: 0),
    );
  }

  Widget _buildCoachAttendanceList() {
    final coachesAsync = ref.watch(coachesForAttendanceProvider);

    return coachesAsync.when(
      data: (coaches) {
        if (coaches.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            child: Text(
              'No coaches available',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendance List Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: Text(
                'Mark Attendance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ...coaches.map((coach) {
              final attendanceStatus = _attendance[coach.id];
              return _AttendanceItem(
                name: coach.specialization != null
                    ? '${coach.name} - ${coach.specialization}'
                    : coach.name,
                isPresent: attendanceStatus == 'present',
                hasSelection: attendanceStatus != null,
                remark: _remarks[coach.id] ?? '',
                onPresentChanged: (isPresent) {
                  setState(() {
                    if (isPresent) {
                      _attendance[coach.id] = 'present';
                    } else {
                      _attendance[coach.id] = 'absent';
                    }
                    _hasUnsavedChanges = true;
                  });
                },
                onRemarkChanged: (remark) {
                  setState(() {
                    _remarks[coach.id] = remark;
                    _hasUnsavedChanges = true;
                  });
                },
              );
            }),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: ListSkeleton(itemCount: 3),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: ErrorDisplay(
          message: 'Failed to load coaches',
          onRetry: () => ref.invalidate(coachesForAttendanceProvider),
        ),
      ),
    );
  }

  Future<void> _saveAttendance() async {
    if (_attendance.isEmpty) return;

    try {
      final attendanceService = ref.read(attendanceServiceProvider);

      if (_attendanceType == 'students' && _selectedBatchId != null) {
        // Save student attendance using bulk endpoint
        final attendanceList = _attendance.entries.map((entry) {
          return {
            'student_id': entry.key,
            'batch_id': _selectedBatchId!,
            'date': _selectedDate,
            'status': entry.value,
            'remarks': _remarks[entry.key],
          };
        }).toList();

        await attendanceService.markMultipleAttendance(attendanceList);
      } else if (_attendanceType == 'coaches') {
        // Save coach attendance
        for (final entry in _attendance.entries) {
          await attendanceService.markCoachAttendance(
            coachId: entry.key,
            date: _selectedDate,
            status: entry.value,
            remarks: _remarks[entry.key],
          );
        }
      }

      if (mounted) {
        SuccessSnackbar.show(context, 'Attendance saved successfully');

        // Invalidate providers to refresh data
        if (_attendanceType == 'students' && _selectedBatchId != null) {
          ref.invalidate(
            studentAttendanceProvider(_selectedDate, _selectedBatchId!),
          );
        } else if (_attendanceType == 'coaches') {
          ref.invalidate(
            coachAttendanceProvider(_selectedDate),
          );
        }

        // Reload attendance from database to reflect saved changes
        await Future.delayed(const Duration(milliseconds: 200)); // Small delay for DB commit
        if (_attendanceType == 'students' && _selectedBatchId != null) {
          await _loadExistingAttendance();
        } else if (_attendanceType == 'coaches') {
          await _loadExistingCoachAttendance();
        }
        // _hasUnsavedChanges is reset in the load methods
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _cancelAttendance() {
    // Reload attendance from database to discard changes
    if (_attendanceType == 'students' && _selectedBatchId != null) {
      _loadExistingAttendance();
    } else if (_attendanceType == 'coaches') {
      _loadExistingCoachAttendance();
    }
    // _hasUnsavedChanges is reset in the load methods
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedBatchId == null) return;

    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      final existingAttendance = await attendanceService.getAttendance(
        date: _selectedDate,
        batchId: _selectedBatchId,
      );

      setState(() {
        _attendance.clear();
        _remarks.clear();
        for (final record in existingAttendance) {
          _attendance[record.studentId] = record.status;
          if (record.remarks != null) {
            _remarks[record.studentId] = record.remarks!;
          }
        }
        _hasUnsavedChanges = false; // Reset flag after loading
      });
    } catch (e) {
      // Silently fail - user can mark attendance fresh
    }
  }

  Future<void> _loadExistingCoachAttendance() async {
    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      final existingAttendance = await attendanceService.getCoachAttendance(
        date: _selectedDate,
      );

      setState(() {
        _attendance.clear();
        _remarks.clear();
        for (final record in existingAttendance) {
          _attendance[record.coachId] = record.status;
          if (record.remarks != null) {
            _remarks[record.coachId] = record.remarks!;
          }
        }
        _hasUnsavedChanges = false; // Reset flag after loading
      });
    } catch (e) {
      // Silently fail - user can mark attendance fresh
    }
  }

}

class _TypeSelectorButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TypeSelectorButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isActive ? NeumorphicStyles.getPressedShadow() : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.iconActive : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.iconActive : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceItem extends StatelessWidget {
  final String name;
  final bool isPresent;
  final bool hasSelection;
  final String remark;
  final ValueChanged<bool> onPresentChanged;
  final ValueChanged<String> onRemarkChanged;

  const _AttendanceItem({
    required this.name,
    required this.isPresent,
    this.hasSelection = false,
    required this.remark,
    required this.onPresentChanged,
    required this.onRemarkChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Present Button
              GestureDetector(
                onTap: () => onPresentChanged(true),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasSelection && isPresent
                        ? AppColors.success
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: hasSelection && isPresent
                        ? NeumorphicStyles.getInsetShadow()
                        : NeumorphicStyles.getElevatedShadow(),
                  ),
                  child: Icon(
                    Icons.check,
                    color: hasSelection && isPresent
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Absent Button
              GestureDetector(
                onTap: () => onPresentChanged(false),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasSelection && !isPresent
                        ? AppColors.error
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: hasSelection && !isPresent
                        ? NeumorphicStyles.getInsetShadow()
                        : NeumorphicStyles.getElevatedShadow(),
                  ),
                  child: Icon(
                    Icons.close,
                    color: hasSelection && !isPresent
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          NeumorphicInsetContainer(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Add remarks...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 12),
                border: InputBorder.none,
              ),
              onChanged: onRemarkChanged,
            ),
          ),
        ],
      ),
    );
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
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
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
