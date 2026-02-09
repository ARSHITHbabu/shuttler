import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/batch_provider.dart';
import '../../models/attendance.dart';

/// Student Attendance Screen - READ-ONLY view of attendance history
/// Students can view their attendance records but cannot mark attendance
class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> {
  // Filter options
  String _selectedFilter = 'all'; // 'all', 'present', 'absent'
  String _selectionMode = 'month'; // 'date', 'month', 'year', 'all'
  DateTime? _selectedDate;
  DateTime? _selectedMonth;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _selectedYear = DateTime.now().year;
  }

  // Calculate stats from attendance records
  Map<String, dynamic> _calculateStats(List<Attendance> records) {
    if (records.isEmpty) {
      return {
        'total_days': 0,
        'present_days': 0,
        'absent_days': 0,
        'attendance_rate': 0.0,
      };
    }

    final total = records.length;
    final present = records.where((r) => r.status.toLowerCase() == 'present').length;
    final absent = total - present;

    return {
      'total_days': total,
      'present_days': present,
      'absent_days': absent,
      'attendance_rate': total > 0 ? (present / total * 100) : 0.0,
    };
  }

  List<Attendance> _filterRecords(List<Attendance> records) {
    if (_selectedFilter == 'all') {
      return records;
    }
    return records.where((record) => record.status.toLowerCase() == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get user ID from auth provider
    final authStateAsync = ref.watch(authProvider);
    
    return authStateAsync.when(
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: ListSkeleton(itemCount: 5)),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ErrorDisplay(
          message: 'Failed to load user data: ${error.toString()}',
          onRetry: () => ref.invalidate(authProvider),
        ),
      ),
      data: (authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: ErrorDisplay(
              message: 'Please log in to view attendance records',
              onRetry: () => ref.invalidate(authProvider),
            ),
          );
        }

        final userId = authState.userId;
        
        // Determine date range based on selection mode
        DateTime? startDate;
        DateTime? endDate;
        int? month;
        int? year;
        
        if (_selectionMode == 'date' && _selectedDate != null) {
          // Single date selection
          startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
          endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
        } else if (_selectionMode == 'month' && _selectedMonth != null) {
          // Month selection
          month = _selectedMonth!.month;
          year = _selectedMonth!.year;
        } else if (_selectionMode == 'year' && _selectedYear != null) {
          // Year selection
          startDate = DateTime(_selectedYear!, 1, 1);
          endDate = DateTime(_selectedYear!, 12, 31, 23, 59, 59);
        }
        // If 'all', startDate and endDate remain null
        
        final attendanceAsync = ref.watch(attendanceByStudentProvider(
          userId,
          startDate: startDate,
          endDate: endDate,
          month: month,
          year: year,
        ));
        
        // Fetch batches to get batch names
        final batchesAsync = ref.watch(studentBatchesProvider(userId));

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () async {
              DateTime? startDate;
              DateTime? endDate;
              int? month;
              int? year;
              
              if (_selectionMode == 'date' && _selectedDate != null) {
                startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
              } else if (_selectionMode == 'month' && _selectedMonth != null) {
                month = _selectedMonth!.month;
                year = _selectedMonth!.year;
              } else if (_selectionMode == 'year' && _selectedYear != null) {
                startDate = DateTime(_selectedYear!, 1, 1);
                endDate = DateTime(_selectedYear!, 12, 31, 23, 59, 59);
              }
              
              ref.invalidate(attendanceByStudentProvider(
                userId,
                startDate: startDate,
                endDate: endDate,
                month: month,
                year: year,
              ));
              ref.invalidate(studentBatchesProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: Text(
                    'My Attendance',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                ),

                // Content
                SliverToBoxAdapter(
                  child: attendanceAsync.when(
                    loading: () => const SizedBox(
                      height: 400,
                      child: ListSkeleton(itemCount: 3),
                    ),
                    error: (error, stack) => ErrorDisplay(
                      message: 'Failed to load attendance records: ${error.toString()}',
                      onRetry: () {
                        DateTime? startDate;
                        DateTime? endDate;
                        int? month;
                        int? year;
                        
                        if (_selectionMode == 'date' && _selectedDate != null) {
                          startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                          endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
                        } else if (_selectionMode == 'month' && _selectedMonth != null) {
                          month = _selectedMonth!.month;
                          year = _selectedMonth!.year;
                        } else if (_selectionMode == 'year' && _selectedYear != null) {
                          startDate = DateTime(_selectedYear!, 1, 1);
                          endDate = DateTime(_selectedYear!, 12, 31, 23, 59, 59);
                        }
                        
                        ref.invalidate(attendanceByStudentProvider(
                          userId,
                          startDate: startDate,
                          endDate: endDate,
                          month: month,
                          year: year,
                        ));
                      },
                    ),
                    data: (attendanceRecords) {
                      return batchesAsync.when(
                        data: (batches) {
                          final batchMap = {for (var b in batches) b.id: b.name};
                          final enrichedRecords = attendanceRecords.map((record) {
                            if (record.batchName == null || record.batchName == 'Unknown Batch') {
                              final batchName = batchMap[record.batchId] ?? 'Unknown Batch';
                              return Attendance(
                                id: record.id,
                                studentId: record.studentId,
                                studentName: record.studentName,
                                batchId: record.batchId,
                                batchName: batchName,
                                date: record.date,
                                status: record.status,
                                remarks: record.remarks,
                                createdAt: record.createdAt,
                              );
                            }
                            return record;
                          }).toList();
                          
                          final attendanceStats = _calculateStats(enrichedRecords);

                          return Column(
                            children: [
                              // Stats Summary
                              _buildStatsSummary(isDark, attendanceStats),

                              const SizedBox(height: AppDimensions.spacingL),

                              // Date/Month/Year Selector
                              _buildDateSelector(isDark),

                              const SizedBox(height: AppDimensions.spacingM),

                              // Filter Tabs
                              _buildFilterTabs(isDark),

                              const SizedBox(height: AppDimensions.spacingL),

                              // History Header
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Attendance History',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${_filterRecords(enrichedRecords).length} sessions',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingM),
                            ],
                          );
                        },
                        loading: () {
                          final attendanceStats = _calculateStats(attendanceRecords);
                          return Column(
                            children: [
                              _buildStatsSummary(isDark, attendanceStats),
                              const SizedBox(height: AppDimensions.spacingL),
                              _buildDateSelector(isDark),
                              const SizedBox(height: AppDimensions.spacingM),
                              _buildFilterTabs(isDark),
                              const SizedBox(height: AppDimensions.spacingM),
                            ],
                          );
                        },
                        error: (_, __) {
                          final attendanceStats = _calculateStats(attendanceRecords);
                          return Column(
                            children: [
                              _buildStatsSummary(isDark, attendanceStats),
                              const SizedBox(height: AppDimensions.spacingL),
                              _buildDateSelector(isDark),
                              const SizedBox(height: AppDimensions.spacingM),
                              _buildFilterTabs(isDark),
                              const SizedBox(height: AppDimensions.spacingM),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                // Attendance Records List
                attendanceAsync.when(
                  loading: () => const SliverToBoxAdapter(child: SizedBox()),
                  error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                  data: (attendanceRecords) {
                    return batchesAsync.when(
                      data: (batches) {
                        final batchMap = {for (var b in batches) b.id: b.name};
                        final enrichedRecords = attendanceRecords.map((record) {
                          if (record.batchName == null || record.batchName == 'Unknown Batch') {
                            final batchName = batchMap[record.batchId] ?? 'Unknown Batch';
                            return Attendance(
                              id: record.id,
                              studentId: record.studentId,
                              studentName: record.studentName,
                              batchId: record.batchId,
                              batchName: batchName,
                              date: record.date,
                              status: record.status,
                              remarks: record.remarks,
                              createdAt: record.createdAt,
                            );
                          }
                          return record;
                        }).toList();
                        
                        final filteredRecords = _filterRecords(enrichedRecords);
                        
                        if (filteredRecords.isEmpty) {
                          return SliverToBoxAdapter(
                            child: EmptyState.noAttendance(),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final record = filteredRecords[index];
                              return _AttendanceRecordCard(
                                record: record,
                                isDark: isDark,
                              );
                            },
                            childCount: filteredRecords.length,
                          ),
                        );
                      },
                      loading: () {
                        final filteredRecords = _filterRecords(attendanceRecords);
                        if (filteredRecords.isEmpty) {
                          return SliverToBoxAdapter(
                            child: EmptyState.noAttendance(),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final record = filteredRecords[index];
                              return _AttendanceRecordCard(
                                record: record,
                                isDark: isDark,
                              );
                            },
                            childCount: filteredRecords.length,
                          ),
                        );
                      },
                      error: (_, __) {
                        final filteredRecords = _filterRecords(attendanceRecords);
                        if (filteredRecords.isEmpty) {
                          return SliverToBoxAdapter(
                            child: EmptyState.noAttendance(),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final record = filteredRecords[index];
                              return _AttendanceRecordCard(
                                record: record,
                                isDark: isDark,
                              );
                            },
                            childCount: filteredRecords.length,
                          ),
                        );
                      },
                    );
                  },
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSummary(bool isDark, Map<String, dynamic> attendanceStats) {
    final totalDays = (attendanceStats['total_days'] ?? 0) as int;
    final presentDays = (attendanceStats['present_days'] ?? 0) as int;
    final absentDays = (attendanceStats['absent_days'] ?? 0) as int;
    final attendanceRate = (attendanceStats['attendance_rate'] ?? 0.0).toDouble();

    final textP = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textS = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSimpleStat('Total', totalDays.toString(), textP, isDark),
            _buildSimpleStat('Present', presentDays.toString(), isDark ? AppColors.success : AppColorsLight.success, isDark),
            _buildSimpleStat('Absent', absentDays.toString(), isDark ? AppColors.error : AppColorsLight.error, isDark),
            _buildSimpleStat('Percentage', '${attendanceRate.toStringAsFixed(0)}%', textP, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        children: [
          // Selection Mode Tabs
          Row(
            children: [
              Expanded(
                child: _SelectionModeTab(
                  label: 'Date',
                  isSelected: _selectionMode == 'date',
                  isDark: isDark,
                  onTap: () => setState(() => _selectionMode = 'date'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _SelectionModeTab(
                  label: 'Month',
                  isSelected: _selectionMode == 'month',
                  isDark: isDark,
                  onTap: () => setState(() => _selectionMode = 'month'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _SelectionModeTab(
                  label: 'Year',
                  isSelected: _selectionMode == 'year',
                  isDark: isDark,
                  onTap: () => setState(() => _selectionMode = 'year'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _SelectionModeTab(
                  label: 'All',
                  isSelected: _selectionMode == 'all',
                  isDark: isDark,
                  onTap: () => setState(() => _selectionMode = 'all'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Date/Month/Year Display and Navigation
          _buildDateDisplay(isDark),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(bool isDark) {
    if (_selectionMode == 'date') {
      final date = _selectedDate ?? DateTime.now();
      return GestureDetector(
        onTap: () => _showDatePicker(isDark),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _selectedDate = date.subtract(const Duration(days: 1));
                  });
                },
              ),
              Text(
                DateFormat('EEE, d MMM yyyy').format(date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
                ),
                onPressed: () {
                  final now = DateTime.now();
                  final nextDate = date.add(const Duration(days: 1));
                  if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
                    setState(() {
                      _selectedDate = nextDate;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else if (_selectionMode == 'month') {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final currentMonth = _selectedMonth ?? DateTime.now();
      return GestureDetector(
        onTap: () => _showMonthPicker(isDark),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${months[currentMonth.month - 1]} ${currentMonth.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
                ),
                onPressed: () {
                  final now = DateTime.now();
                  if (currentMonth.year < now.year ||
                      (currentMonth.year == now.year && currentMonth.month < now.month)) {
                    setState(() {
                      _selectedMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else if (_selectionMode == 'year') {
      final currentYear = _selectedYear ?? DateTime.now().year;
      return GestureDetector(
        onTap: () => _showYearPicker(isDark),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _selectedYear = currentYear - 1;
                  });
                },
              ),
              Text(
                currentYear.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
                ),
                onPressed: () {
                  final now = DateTime.now();
                  if (currentYear < now.year) {
                    setState(() {
                      _selectedYear = currentYear + 1;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else {
      // All mode
      return NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Center(
          child: Text(
            'All Attendance Records',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
        ),
      );
    }
  }

  void _showDatePicker(bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.accent,
                    surface: AppColors.cardBackground,
                  )
                : const ColorScheme.light(
                    primary: AppColorsLight.accent,
                    surface: AppColorsLight.cardBackground,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showMonthPicker(bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.accent,
                    surface: AppColors.cardBackground,
                  )
                : const ColorScheme.light(
                    primary: AppColorsLight.accent,
                    surface: AppColorsLight.cardBackground,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  void _showYearPicker(bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear ?? DateTime.now().year),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.accent,
                    surface: AppColors.cardBackground,
                  )
                : const ColorScheme.light(
                    primary: AppColorsLight.accent,
                    surface: AppColorsLight.cardBackground,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
      });
    }
  }

  Widget _buildFilterTabs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Row(
        children: [
          Expanded(
            child: _FilterTab(
              label: 'All',
              isSelected: _selectedFilter == 'all',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'all'),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: _FilterTab(
              label: 'Present',
              isSelected: _selectedFilter == 'present',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'present'),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: _FilterTab(
              label: 'Absent',
              isSelected: _selectedFilter == 'absent',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'absent'),
            ),
          ),
        ],
      ),
    );
  }

  // Removed _buildEmptyState - using EmptyState.noAttendance() instead

  Color _getAttendanceColor(double rate, bool isDark) {
    if (rate >= 80) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (rate >= 60) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SelectionModeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SelectionModeTab({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.accent : AppColorsLight.accent)
              : (isDark ? AppColors.cardBackground : AppColorsLight.cardBackground),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          boxShadow: isSelected ? null : NeumorphicStyles.getElevatedShadow(),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.accent : AppColorsLight.accent)
              : (isDark ? AppColors.cardBackground : AppColorsLight.cardBackground),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isSelected ? null : NeumorphicStyles.getElevatedShadow(),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  final Attendance record;
  final bool isDark;

  const _AttendanceRecordCard({
    required this.record,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final status = record.status;
    final date = record.date;
    final batchName = record.batchName ?? 'Unknown Batch';
    final remarks = record.remarks ?? '';

    final isPresent = status.toLowerCase() == 'present';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingS,
      ),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPresent
                    ? (isDark ? AppColors.success : AppColorsLight.success).withValues(alpha: 0.1)
                    : (isDark ? AppColors.error : AppColorsLight.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                color: isPresent
                    ? (isDark ? AppColors.success : AppColorsLight.success)
                    : (isDark ? AppColors.error : AppColorsLight.error),
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(date.toIso8601String()),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    batchName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                  if (remarks.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      remarks,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: isPresent
                    ? (isDark ? AppColors.success : AppColorsLight.success).withValues(alpha: 0.1)
                    : (isDark ? AppColors.error : AppColorsLight.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                isPresent ? 'Present' : 'Absent',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPresent
                      ? (isDark ? AppColors.success : AppColorsLight.success)
                      : (isDark ? AppColors.error : AppColorsLight.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
