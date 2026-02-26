import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/standard_page_header.dart';
import '../../providers/batch_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/service_providers.dart';

/// Attendance Screen - Take and view attendance
/// Matches React reference: AttendanceScreen.tsx
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedBatchId;
  String _attendanceType = 'student'; // 'student' or 'coach'
  final Map<int, String> _attendance = {}; // studentId/coachId -> 'present' or 'absent'
  final Map<int, String> _remarks = {}; // studentId/coachId -> remarks
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: context.cardBackgroundColor,
              onSurface: context.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        if (_attendanceType == 'student' && _selectedBatchId != null) {
          _loadExistingAttendance();
        } else if (_attendanceType == 'coach') {
          _loadExistingCoachAttendance();
        }
      });
    }
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedBatchId == null) return;
    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      final existingAttendance = await attendanceService.getAttendance(
        date: _selectedDate,
        batchId: _selectedBatchId,
      );
      if (mounted) {
        setState(() {
          _attendance.clear();
          _remarks.clear();
          for (final record in existingAttendance) {
            _attendance[record.studentId] = record.status;
            if (record.remarks != null) _remarks[record.studentId] = record.remarks!;
          }
          _hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadExistingCoachAttendance() async {
    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      final existingAttendance = await attendanceService.getCoachAttendance(date: _selectedDate);
      if (mounted) {
        setState(() {
          _attendance.clear();
          _remarks.clear();
          for (final record in existingAttendance) {
            _attendance[record.coachId] = record.status;
            if (record.remarks != null) _remarks[record.coachId] = record.remarks!;
          }
          _hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveAttendance() async {
    if (_attendance.isEmpty) return;
    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      if (_attendanceType == 'student' && _selectedBatchId != null) {
        final attendanceList = _attendance.entries.map((entry) => {
          'student_id': entry.key,
          'batch_id': _selectedBatchId!,
          'date': _selectedDate,
          'status': entry.value,
          'remarks': _remarks[entry.key],
        }).toList();
        await attendanceService.markMultipleAttendance(attendanceList);
      } else if (_attendanceType == 'coach') {
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
        _hasUnsavedChanges = false;
      }
    } catch (e) {
      if (mounted) SuccessSnackbar.showError(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppDimensions.getScreenPadding(context);
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
                const StandardPageHeader(title: 'Attendance'),
                const SizedBox(height: AppDimensions.spacingS),
                
                // Type Selector
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FilterButton(
                            label: 'Students',
                            isSelected: _attendanceType == 'student',
                            onTap: () => setState(() {
                              _attendanceType = 'student';
                              _selectedBatchId = null;
                              _attendance.clear();
                              _remarks.clear();
                              _hasUnsavedChanges = false;
                            }),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _FilterButton(
                            label: 'Coaches',
                            isSelected: _attendanceType == 'coach',
                            onTap: () {
                              setState(() {
                                _attendanceType = 'coach';
                                _selectedBatchId = null;
                                _attendance.clear();
                                _remarks.clear();
                                _hasUnsavedChanges = false;
                              });
                              _loadExistingCoachAttendance();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacingM),
                
                // Date & Batch Selectors
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeumorphicInsetContainer(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          onTap: () => _selectDate(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      if (_attendanceType == 'student') ...[
                        const SizedBox(width: AppDimensions.spacingM),
                        Expanded(
                          child: batchesAsync.when(
                            data: (batches) {
                              final activeBatches = batches.where((b) => b.status == 'active').toList();
                              return NeumorphicInsetContainer(
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: _selectedBatchId,
                                    hint: const Text('Batch', style: TextStyle(fontSize: 14)),
                                    items: activeBatches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 14)))).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedBatchId = val;
                                        _attendance.clear();
                                        _remarks.clear();
                                        _hasUnsavedChanges = false;
                                      });
                                      _loadExistingAttendance();
                                    },
                                  ),
                                ),
                              );
                            },
                            loading: () => const SizedBox(height: 48),
                            error: (_, __) => const SizedBox(height: 48),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacingL),
                
                // List content
                if (_attendanceType == 'student' && _selectedBatchId != null)
                  _buildStudentList(padding)
                else if (_attendanceType == 'coach')
                  _buildCoachList(padding),
                
                // Save Button
                if (_hasUnsavedChanges)
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: ElevatedButton(
                      onPressed: _saveAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Save Attendance', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentList(double padding) {
    final studentsAsync = ref.watch(batchStudentsForAttendanceProvider(_selectedBatchId!));
    return studentsAsync.when(
      data: (students) => Column(
        children: students.map((s) => _AttendanceItem(
          name: s.name,
          status: _attendance[s.id],
          onChanged: (status) => setState(() {
            _attendance[s.id] = status;
            _hasUnsavedChanges = true;
          }),
          padding: padding,
        )).toList(),
      ),
      loading: () => Padding(padding: EdgeInsets.all(padding), child: const ListSkeleton(itemCount: 5)),
      error: (_, __) => const ErrorDisplay(message: 'Failed to load students'),
    );
  }

  Widget _buildCoachList(double padding) {
    final coachesAsync = ref.watch(coachesForAttendanceProvider);
    return coachesAsync.when(
      data: (coaches) => Column(
        children: coaches.map((c) => _AttendanceItem(
          name: c.name,
          status: _attendance[c.id],
          onChanged: (status) => setState(() {
            _attendance[c.id] = status;
            _hasUnsavedChanges = true;
          }),
          padding: padding,
        )).toList(),
      ),
      loading: () => Padding(padding: EdgeInsets.all(padding), child: const ListSkeleton(itemCount: 5)),
      error: (_, __) => const ErrorDisplay(message: 'Failed to load coaches'),
    );
  }
}

class _AttendanceItem extends StatelessWidget {
  final String name;
  final String? status;
  final Function(String) onChanged;
  final double padding;

  const _AttendanceItem({required this.name, this.status, required this.onChanged, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
            Row(
              children: [
                _StatusCircle(
                  icon: Icons.check,
                  color: AppColors.success,
                  isSelected: status == 'present',
                  onTap: () => onChanged('present'),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                _StatusCircle(
                  icon: Icons.close,
                  color: AppColors.error,
                  isSelected: status == 'absent',
                  onTap: () => onChanged('absent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusCircle({required this.icon, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, size: 20, color: isSelected ? Colors.white : color),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accent : context.textSecondaryColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
