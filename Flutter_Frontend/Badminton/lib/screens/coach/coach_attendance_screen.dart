import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/service_providers.dart';
import '../../models/student.dart';
import '../../models/batch.dart';
import '../../models/attendance.dart';

enum AttendanceViewMode { student, personal }

/// Coach Attendance Screen - Mark attendance for assigned batches
/// Matches Owner Attendance Screen UI and workflow
class CoachAttendanceScreen extends ConsumerStatefulWidget {
  final AttendanceViewMode? initialMode;
  const CoachAttendanceScreen({super.key, this.initialMode});

  @override
  ConsumerState<CoachAttendanceScreen> createState() => _CoachAttendanceScreenState();
}

class _CoachAttendanceScreenState extends ConsumerState<CoachAttendanceScreen> {
  late AttendanceViewMode _viewMode;
  int? _selectedBatchId;
  DateTime _selectedDate = DateTime.now();
  final Map<int, String> _attendance = {}; // studentId -> 'present' or 'absent'
  final Map<int, String> _remarks = {}; // studentId -> remarks
  bool _hasUnsavedChanges = false; // Track if there are unsaved changes

  // Personal Attendance State (Coach's own)
  String _selectedFilter = 'all'; // 'all', 'present', 'absent'
  String _selectionMode = 'month'; // 'date', 'month', 'year', 'all'
  DateTime? _pSelectedDate;
  DateTime? _pSelectedMonth;
  int? _pSelectedYear;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initialMode ?? AttendanceViewMode.student;
    _pSelectedMonth = DateTime.now();
    _pSelectedDate = DateTime.now();
    _pSelectedYear = DateTime.now().year;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_viewMode == AttendanceViewMode.personal)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                          onPressed: () => ref.invalidate(coachAttendanceByCoachIdProvider(coachId)),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Mode Toggle
                  _buildModeToggle(),

                  const SizedBox(height: AppDimensions.spacingL),

                  if (_viewMode == AttendanceViewMode.student)
                    _buildStudentAttendanceView(coachId)
                  else
                    _buildPersonalAttendanceView(coachId),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeToggle() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      child: Row(
        children: [
          Expanded(
            child: _ToggleItem(
              label: 'Student Attendance',
              isSelected: _viewMode == AttendanceViewMode.student,
              onTap: () => setState(() => _viewMode = AttendanceViewMode.student),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: _ToggleItem(
              label: 'My Attendance',
              isSelected: _viewMode == AttendanceViewMode.personal,
              onTap: () => setState(() => _viewMode = AttendanceViewMode.personal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceView(int coachId) {
    final batchesAsync = ref.watch(coachBatchesProvider(coachId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      if (_selectedBatchId != null) {
                        _loadExistingAttendance();
                      }
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

        // Batch Selector (card-based, matching owner screen)
        if (_selectedBatchId == null)
          _buildBatchSelector(batchesAsync, coachId)
        else
          _buildStudentAttendanceList(batchesAsync, coachId),
      ],
    );
  }

  Widget _buildPersonalAttendanceView(int coachId) {
    // Determine date range based on selection mode
    DateTime? startDate;
    DateTime? endDate;
    int? month;
    int? year;

    if (_selectionMode == 'date' && _pSelectedDate != null) {
      startDate = DateTime(_pSelectedDate!.year, _pSelectedDate!.month, _pSelectedDate!.day);
      endDate = DateTime(_pSelectedDate!.year, _pSelectedDate!.month, _pSelectedDate!.day, 23, 59, 59);
    } else if (_selectionMode == 'month' && _pSelectedMonth != null) {
      month = _pSelectedMonth!.month;
      year = _pSelectedMonth!.year;
    } else if (_selectionMode == 'year' && _pSelectedYear != null) {
      startDate = DateTime(_pSelectedYear!, 1, 1);
      endDate = DateTime(_pSelectedYear!, 12, 31, 23, 59, 59);
    }

    final attendanceAsync = ref.watch(coachAttendanceByCoachIdProvider(coachId));

    return attendanceAsync.when(
      loading: () => const Center(child: ListSkeleton(itemCount: 3)),
      error: (error, stack) => ErrorDisplay(
        message: 'Failed to load attendance records: ${error.toString()}',
        onRetry: () => ref.invalidate(coachAttendanceByCoachIdProvider(coachId)),
      ),
      data: (allRecords) {
        // Filter records based on selected date/month/year and present/absent filter
        final filteredByDate = allRecords.where((record) {
          if (_selectionMode == 'date' && _pSelectedDate != null) {
            return record.date.year == _pSelectedDate!.year &&
                record.date.month == _pSelectedDate!.month &&
                record.date.day == _pSelectedDate!.day;
          } else if (_selectionMode == 'month' && _pSelectedMonth != null) {
            return record.date.year == _pSelectedMonth!.year &&
                record.date.month == _pSelectedMonth!.month;
          } else if (_selectionMode == 'year' && _pSelectedYear != null) {
            return record.date.year == _pSelectedYear;
          }
          return true; // All mode
        }).toList();

        final filteredRecords = _selectedFilter == 'all'
            ? filteredByDate
            : filteredByDate.where((r) => r.status.toLowerCase() == _selectedFilter).toList();

        final stats = _calculatePersonalStats(filteredByDate);

        return Column(
          children: [
            // Stats Summary row
            _buildPersonalStatsSummary(stats),

            const SizedBox(height: AppDimensions.spacingL),

            // Date/Month/Year Selector
            _buildPersonalDateSelector(),

            const SizedBox(height: AppDimensions.spacingM),

            // Filter Tabs (All, Present, Absent)
            _buildPersonalFilterTabs(),

            const SizedBox(height: AppDimensions.spacingL),

            // History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${filteredRecords.length} sessions',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),

            if (filteredRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
                      const SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'No attendance records found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRecords.length,
                itemBuilder: (context, index) {
                  return _PersonalAttendanceRecordCard(record: filteredRecords[index]);
                },
              ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _calculatePersonalStats(List<CoachAttendance> records) {
    if (records.isEmpty) {
      return {
        'total': 0,
        'present': 0,
        'absent': 0,
        'rate': 0.0,
      };
    }
    final total = records.length;
    final present = records.where((r) => r.status.toLowerCase() == 'present').length;
    final absent = total - present;
    return {
      'total': total,
      'present': present,
      'absent': absent,
      'rate': (present / total) * 100,
    };
  }

  Widget _buildPersonalStatsSummary(Map<String, dynamic> stats) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PersonalStatItem(label: 'Total', value: stats['total'].toString(), color: AppColors.textPrimary),
          _PersonalStatItem(label: 'Present', value: stats['present'].toString(), color: AppColors.success),
          _PersonalStatItem(label: 'Absent', value: stats['absent'].toString(), color: AppColors.error),
          _PersonalStatItem(label: 'Percentage', value: '${(stats['rate'] as double).toStringAsFixed(0)}%', color: AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildPersonalDateSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SelectionTab(label: 'Date', isSelected: _selectionMode == 'date', onTap: () => setState(() => _selectionMode = 'date'))),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(child: _SelectionTab(label: 'Month', isSelected: _selectionMode == 'month', onTap: () => setState(() => _selectionMode = 'month'))),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(child: _SelectionTab(label: 'Year', isSelected: _selectionMode == 'year', onTap: () => setState(() => _selectionMode = 'year'))),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(child: _SelectionTab(label: 'All', isSelected: _selectionMode == 'all', onTap: () => setState(() => _selectionMode = 'all'))),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        _buildPersonalDateDisplay(),
      ],
    );
  }

  Widget _buildPersonalDateDisplay() {
    if (_selectionMode == 'all') {
      return NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: const Center(child: Text('All Attendance Records', style: TextStyle(fontWeight: FontWeight.w600))),
      );
    }

    String displayTitle = '';
    if (_selectionMode == 'date') displayTitle = DateFormat('EEE, d MMM yyyy').format(_pSelectedDate!);
    if (_selectionMode == 'month') displayTitle = DateFormat('MMMM yyyy').format(_pSelectedMonth!);
    if (_selectionMode == 'year') displayTitle = _pSelectedYear.toString();

    return GestureDetector(
      onTap: () => _showPersonalDatePicker(),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _navigatePersonalDate(-1),
            ),
            Text(displayTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _navigatePersonalDate(1),
            ),
          ],
        ),
      ),
    );
  }

  void _navigatePersonalDate(int direction) {
    setState(() {
      if (_selectionMode == 'date') _pSelectedDate = _pSelectedDate!.add(Duration(days: direction));
      if (_selectionMode == 'month') _pSelectedMonth = DateTime(_pSelectedMonth!.year, _pSelectedMonth!.month + direction);
      if (_selectionMode == 'year') _pSelectedYear = _pSelectedYear! + direction;
    });
  }

  void _showPersonalDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectionMode == 'date' ? _pSelectedDate! : _pSelectedMonth!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: _selectionMode == 'date' ? DatePickerMode.day : DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        if (_selectionMode == 'date') _pSelectedDate = picked;
        if (_selectionMode == 'month') _pSelectedMonth = picked;
        if (_selectionMode == 'year') _pSelectedYear = picked.year;
      });
    }
  }

  Widget _buildPersonalFilterTabs() {
    return Row(
      children: [
        Expanded(child: _FilterTabItem(label: 'All', isSelected: _selectedFilter == 'all', onTap: () => setState(() => _selectedFilter = 'all'))),
        const SizedBox(width: AppDimensions.spacingS),
        Expanded(child: _FilterTabItem(label: 'Present', isSelected: _selectedFilter == 'present', onTap: () => setState(() => _selectedFilter = 'present'))),
        const SizedBox(width: AppDimensions.spacingS),
        Expanded(child: _FilterTabItem(label: 'Absent', isSelected: _selectedFilter == 'absent', onTap: () => setState(() => _selectedFilter = 'absent'))),
      ],
    );
  }

  Widget _buildBatchSelector(AsyncValue<List<Batch>> batchesAsync, int coachId) {
    return batchesAsync.when(
      data: (batches) {
        if (batches.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            child: Text(
              'No batches assigned to you yet',
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
          onRetry: () => ref.invalidate(coachBatchesProvider(coachId)),
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceList(AsyncValue<List<Batch>> batchesAsync, int coachId) {
    if (_selectedBatchId == null) return const SizedBox.shrink();

    final studentsAsync = ref.watch(
      batchStudentsForAttendanceProvider(_selectedBatchId!),
    );

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
                        _hasUnsavedChanges = false;
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch?.name ?? 'Unknown Batch',
                          style: const TextStyle(
                            fontSize: 18,
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
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Save Attendance'),
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
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Cancel'),
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
          _hasUnsavedChanges = false; // Reset flag after loading
        });
      }
    } catch (e) {
      // Silently fail - user can mark attendance fresh
    }
  }

  void _cancelAttendance() {
    // Reload attendance from database to discard changes
    _loadExistingAttendance();
    // _hasUnsavedChanges is reset in the load method
  }

  Future<void> _saveAttendance() async {
    if (_selectedBatchId == null) {
      SuccessSnackbar.showError(context, 'Please select a batch');
      return;
    }

    if (_attendance.isEmpty) return;

    try {
      final attendanceService = ref.read(attendanceServiceProvider);
      final batchService = ref.read(batchServiceProvider);
      final authState = ref.read(authProvider);
      
      // Get coach name for marked_by field
      final coachName = authState.value is Authenticated 
          ? (authState.value as Authenticated).userName 
          : 'Coach';
      
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
            markedBy: coachName, // Pass coach name to track who marked attendance
          );
        }
      }

      if (mounted) {
        SuccessSnackbar.show(context, 'Attendance saved successfully');

        // Invalidate providers to refresh data
        ref.invalidate(
          studentAttendanceProvider(_selectedDate, _selectedBatchId!),
        );

        // Reload attendance from database to reflect saved changes
        await Future.delayed(const Duration(milliseconds: 200)); // Small delay for DB commit
        await _loadExistingAttendance();
        // _hasUnsavedChanges is reset in the load method
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Error: ${e.toString()}');
      }
    }
  }
}

class _AttendanceItem extends StatefulWidget {
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
  State<_AttendanceItem> createState() => _AttendanceItemState();
}

class _AttendanceItemState extends State<_AttendanceItem> {
  late TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(text: widget.remark);
  }

  @override
  void didUpdateWidget(_AttendanceItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remark != widget.remark) {
      _remarksController.text = widget.remark;
    }
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
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Present Button
              GestureDetector(
                onTap: () => widget.onPresentChanged(true),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.hasSelection && widget.isPresent
                        ? AppColors.success
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: widget.hasSelection && widget.isPresent
                        ? NeumorphicStyles.getInsetShadow()
                        : NeumorphicStyles.getElevatedShadow(),
                  ),
                  child: Icon(
                    Icons.check,
                    color: widget.hasSelection && widget.isPresent
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Absent Button
              GestureDetector(
                onTap: () => widget.onPresentChanged(false),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.hasSelection && !widget.isPresent
                        ? AppColors.error
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: widget.hasSelection && !widget.isPresent
                        ? NeumorphicStyles.getInsetShadow()
                        : NeumorphicStyles.getElevatedShadow(),
                  ),
                  child: Icon(
                    Icons.close,
                    color: widget.hasSelection && !widget.isPresent
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
              controller: _remarksController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Add remarks...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 12),
                border: InputBorder.none,
              ),
              onChanged: widget.onRemarkChanged,
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

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isSelected ? null : NeumorphicStyles.getElevatedShadow(),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PersonalStatItem({
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
            fontWeight: FontWeight.bold,
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

class _SelectionTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          boxShadow: isSelected ? null : NeumorphicStyles.getElevatedShadow(),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isSelected ? null : NeumorphicStyles.getElevatedShadow(),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalAttendanceRecordCard extends StatelessWidget {
  final CoachAttendance record;

  const _PersonalAttendanceRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final isPresent = record.status.toLowerCase() == 'present';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPresent
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                color: isPresent ? AppColors.success : AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE, d MMM yyyy').format(record.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Coach Attendance',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (record.remarks != null && record.remarks!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      record.remarks!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: isPresent
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                isPresent ? 'Present' : 'Absent',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPresent ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
