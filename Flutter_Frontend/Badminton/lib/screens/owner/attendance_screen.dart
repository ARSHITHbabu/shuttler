import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';

/// Attendance Screen - Dual-mode attendance marking
/// Matches React reference: AttendanceScreen.tsx
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String _attendanceType = 'students'; // 'students' or 'coaches'
  String? _selectedBatchId;
  DateTime _selectedDate = DateTime.now();
  final Map<int, String> _attendance = {}; // studentId -> 'present' or 'absent'
  final Map<int, String> _remarks = {}; // studentId -> remarks

  final List<Map<String, dynamic>> _batches = [
    {'id': '1', 'name': 'Morning Batch A', 'time': '6:00 AM - 7:30 AM'},
    {'id': '2', 'name': 'Evening Batch B', 'time': '5:00 PM - 6:30 PM'},
    {'id': '3', 'name': 'Weekend Batch', 'time': '8:00 AM - 9:30 AM'},
  ];

  final List<Map<String, dynamic>> _students = [
    {'id': 1, 'name': 'Arjun Mehta'},
    {'id': 2, 'name': 'Kavya Sharma'},
    {'id': 3, 'name': 'Rohan Patel'},
    {'id': 4, 'name': 'Priya Singh'},
    {'id': 5, 'name': 'Amit Kumar'},
  ];

  final List<Map<String, dynamic>> _coaches = [
    {'id': 1, 'name': 'Rajesh Kumar', 'specialization': 'Singles'},
    {'id': 2, 'name': 'Priya Singh', 'specialization': 'Doubles'},
    {'id': 3, 'name': 'Amit Sharma', 'specialization': 'Junior Training'},
    {'id': 4, 'name': 'Sneha Patel', 'specialization': 'Advanced'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Type Selector
            NeumorphicContainer(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeSelectorButton(
                      label: 'Student Attendance',
                      icon: Icons.people_outline,
                      isActive: _attendanceType == 'students',
                      onTap: () {
                        setState(() {
                          _attendanceType = 'students';
                          _selectedBatchId = null;
                          _attendance.clear();
                          _remarks.clear();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TypeSelectorButton(
                      label: 'Coach Attendance',
                      icon: Icons.person_outline,
                      isActive: _attendanceType == 'coaches',
                      onTap: () {
                        setState(() {
                          _attendanceType = 'coaches';
                          _selectedBatchId = null;
                          _attendance.clear();
                          _remarks.clear();
                        });
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
                        }
                      },
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
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
                ..._batches.map((batch) => Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        onTap: () {
                          setState(() {
                            _selectedBatchId = batch['id'];
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    batch['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    batch['time'],
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
                    ))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                          child: Text(
                            _batches.firstWhere((b) => b['id'] == _selectedBatchId)['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    ..._students.map((student) => _AttendanceItem(
                          name: student['name'],
                          isPresent: _attendance[student['id']] == 'present',
                          remark: _remarks[student['id']] ?? '',
                          onPresentChanged: (isPresent) {
                            setState(() {
                              if (isPresent) {
                                _attendance[student['id']] = 'present';
                              } else {
                                _attendance[student['id']] = 'absent';
                              }
                            });
                          },
                          onRemarkChanged: (remark) {
                            setState(() {
                              _remarks[student['id']] = remark;
                            });
                          },
                        )),
                  ],
                ),
            ],

            // Coach List (for coaches)
            if (_attendanceType == 'coaches') ...[
              ..._coaches.map((coach) => _AttendanceItem(
                    name: '${coach['name']} - ${coach['specialization']}',
                    isPresent: _attendance[coach['id']] == 'present',
                    remark: _remarks[coach['id']] ?? '',
                    onPresentChanged: (isPresent) {
                      setState(() {
                        if (isPresent) {
                          _attendance[coach['id']] = 'present';
                        } else {
                          _attendance[coach['id']] = 'absent';
                        }
                      });
                    },
                    onRemarkChanged: (remark) {
                      setState(() {
                        _remarks[coach['id']] = remark;
                      });
                    },
                  )),
            ],

            const SizedBox(height: AppDimensions.spacingL),

            // Summary
            if ((_attendanceType == 'students' && _selectedBatchId != null) ||
                _attendanceType == 'coaches')
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(
                          label: 'Present',
                          value: _attendance.values.where((v) => v == 'present').length.toString(),
                          color: AppColors.success,
                        ),
                        _SummaryItem(
                          label: 'Absent',
                          value: _attendance.values.where((v) => v == 'absent').length.toString(),
                          color: AppColors.error,
                        ),
                        _SummaryItem(
                          label: 'Total',
                          value: (_attendanceType == 'students'
                                  ? _students.length
                                  : _coaches.length)
                              .toString(),
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    ElevatedButton(
                      onPressed: () {
                        // Save attendance
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attendance saved successfully'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Save Attendance'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
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
  final String remark;
  final ValueChanged<bool> onPresentChanged;
  final ValueChanged<String> onRemarkChanged;

  const _AttendanceItem({
    required this.name,
    required this.isPresent,
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
              GestureDetector(
                onTap: () => onPresentChanged(!isPresent),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPresent ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: NeumorphicStyles.getInsetShadow(),
                  ),
                  child: Icon(
                    isPresent ? Icons.check : Icons.close,
                    color: Colors.white,
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
