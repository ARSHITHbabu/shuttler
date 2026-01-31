import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/more_screen_app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance.dart';

/// Coach Attendance View Screen - Shows coach's own attendance records
class CoachAttendanceViewScreen extends ConsumerStatefulWidget {
  const CoachAttendanceViewScreen({super.key});

  @override
  ConsumerState<CoachAttendanceViewScreen> createState() => _CoachAttendanceViewScreenState();
}

class _CoachAttendanceViewScreenState extends ConsumerState<CoachAttendanceViewScreen> {
  String _selectedFilter = 'all'; // 'all', 'present', 'absent'
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  // Calculate stats from attendance records
  Map<String, dynamic> _calculateStats(List<CoachAttendance> records) {
    if (records.isEmpty) {
      return {
        'total_classes': 0,
        'attended_classes': 0,
        'missed_classes': 0,
        'attendance_rate': 0.0,
      };
    }

    final total = records.length;
    final present = records.where((r) => r.status.toLowerCase() == 'present').length;
    final absent = total - present;

    return {
      'total_classes': total,
      'attended_classes': present,
      'missed_classes': absent,
      'attendance_rate': total > 0 ? (present / total * 100) : 0.0,
    };
  }

  List<CoachAttendance> _filterRecords(List<CoachAttendance> records) {
    // Filter by month if selected
    var filtered = records;
    if (_selectedMonth != null) {
      filtered = records.where((record) {
        return record.date.year == _selectedMonth!.year &&
            record.date.month == _selectedMonth!.month;
      }).toList();
    }

    // Filter by status
    if (_selectedFilter == 'all') {
      return filtered;
    }
    return filtered.where((record) => record.status.toLowerCase() == _selectedFilter).toList();
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return AppColors.success;
    if (rate >= 75) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Attendance')),
            body: const Center(
              child: Text(
                'Please login',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          );
        }

        final coachId = authValue.userId;
        return _buildScaffold(coachId);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('My Attendance')),
        body: const Center(child: DashboardSkeleton()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('My Attendance')),
        body: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(int coachId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attendanceAsync = ref.watch(coachAttendanceByCoachIdProvider(coachId));

    void _handleReload() {
      ref.invalidate(coachAttendanceByCoachIdProvider(coachId));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: MoreScreenAppBar(
        title: 'Attendance Rate',
        onReload: _handleReload,
        isDark: isDark,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _handleReload();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: attendanceAsync.when(
          loading: () => const Center(child: ListSkeleton(itemCount: 5)),
          error: (error, stack) => ErrorDisplay(
            message: 'Failed to load attendance records: ${error.toString()}',
            onRetry: () => ref.invalidate(coachAttendanceByCoachIdProvider(coachId)),
          ),
          data: (allRecords) {
            final filteredRecords = _filterRecords(allRecords);
            final attendanceStats = _calculateStats(allRecords);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Stats Summary
                  _buildStatsSummary(attendanceStats),
                  
                  const SizedBox(height: AppDimensions.spacingL),
                  
                  // Month Selector and Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                    child: Column(
                      children: [
                        // Month Selector
                        NeumorphicContainer(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: AppDimensions.spacingM),
                              Expanded(
                                child: Text(
                                  _selectedMonth != null
                                      ? DateFormat('MMMM yyyy').format(_selectedMonth!)
                                      : 'All Time',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedMonth ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                    initialDatePickerMode: DatePickerMode.year,
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedMonth = picked;
                                    });
                                  }
                                },
                                child: const Text('Select Month'),
                              ),
                              if (_selectedMonth != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedMonth = null;
                                    });
                                  },
                                  child: const Text('Clear'),
                                ),
                            ],
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
                                label: 'Present',
                                isSelected: _selectedFilter == 'present',
                                onTap: () => setState(() => _selectedFilter = 'present'),
                                color: AppColors.success,
                              ),
                              const SizedBox(width: AppDimensions.spacingS),
                              _FilterChip(
                                label: 'Absent',
                                isSelected: _selectedFilter == 'absent',
                                onTap: () => setState(() => _selectedFilter = 'absent'),
                                color: AppColors.error,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spacingL),
                  
                  // Attendance Records List
                  if (filteredRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.event_busy,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppDimensions.spacingM),
                            Text(
                              _selectedFilter == 'all'
                                  ? 'No attendance records found'
                                  : 'No $_selectedFilter records found',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          ...filteredRecords.map((record) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                              child: NeumorphicContainer(
                                padding: const EdgeInsets.all(AppDimensions.paddingM),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: record.status.toLowerCase() == 'present'
                                            ? AppColors.success.withOpacity(0.2)
                                            : AppColors.error.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                      ),
                                      child: Icon(
                                        record.status.toLowerCase() == 'present'
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: record.status.toLowerCase() == 'present'
                                            ? AppColors.success
                                            : AppColors.error,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.spacingM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('EEEE, MMMM d, yyyy').format(record.date),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppDimensions.spacingS,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: record.status.toLowerCase() == 'present'
                                                  ? AppColors.success
                                                  : AppColors.error,
                                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                            ),
                                            child: Text(
                                              record.status.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (record.remarks != null && record.remarks!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              record.remarks!,
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
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsSummary(Map<String, dynamic> stats) {
    final totalClasses = stats['total_classes'] as int;
    final attendedClasses = stats['attended_classes'] as int;
    final missedClasses = stats['missed_classes'] as int;
    final attendanceRate = stats['attendance_rate'] as double;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            // Attendance Rate Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: (attendanceRate / 100).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: AppColors.cardBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getAttendanceColor(attendanceRate),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${attendanceRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _getAttendanceColor(attendanceRate),
                      ),
                    ),
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            // Stats Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Total Classes',
                  value: totalClasses.toString(),
                  color: AppColors.textPrimary,
                ),
                _StatItem(
                  label: 'Attended',
                  value: attendedClasses.toString(),
                  color: AppColors.success,
                ),
                _StatItem(
                  label: 'Missed',
                  value: missedClasses.toString(),
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
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
