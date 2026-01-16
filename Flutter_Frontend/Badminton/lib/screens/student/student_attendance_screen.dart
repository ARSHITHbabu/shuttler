import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/service_providers.dart';

/// Student Attendance Screen - READ-ONLY view of attendance history
/// Students can view their attendance records but cannot mark attendance
class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _attendanceRecords = [];
  Map<String, dynamic> _attendanceStats = {};
  String? _error;

  // Filter options
  String _selectedFilter = 'all'; // 'all', 'present', 'absent'
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final storageService = ref.read(storageServiceProvider);
      final apiService = ref.read(apiServiceProvider);
      final userId = storageService.getUserId();

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Load attendance records
      try {
        final response = await apiService.get(
          '/api/students/$userId/attendance',
          queryParameters: {
            if (_selectedMonth != null) 'month': _selectedMonth!.month.toString(),
            if (_selectedMonth != null) 'year': _selectedMonth!.year.toString(),
          },
        );
        if (response.statusCode == 200) {
          _attendanceRecords = List<Map<String, dynamic>>.from(response.data['records'] ?? []);
          _attendanceStats = Map<String, dynamic>.from(response.data['stats'] ?? {});
        }
      } catch (e) {
        // Endpoint may not exist yet - use empty data
        _attendanceRecords = [];
        _attendanceStats = {
          'total_days': 0,
          'present_days': 0,
          'absent_days': 0,
          'attendance_rate': 0.0,
        };
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredRecords {
    if (_selectedFilter == 'all') {
      return _attendanceRecords;
    }
    return _attendanceRecords.where((record) => record['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadData,
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
              child: _isLoading
                  ? const SizedBox(
                      height: 400,
                      child: Center(child: LoadingSpinner()),
                    )
                  : _error != null
                      ? _buildErrorWidget(isDark)
                      : Column(
                          children: [
                            // Stats Summary
                            _buildStatsSummary(isDark),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Month Selector
                            _buildMonthSelector(isDark),

                            const SizedBox(height: AppDimensions.spacingM),

                            // Filter Tabs
                            _buildFilterTabs(isDark),

                            const SizedBox(height: AppDimensions.spacingM),
                          ],
                        ),
            ),

            // Attendance Records List
            if (!_isLoading && _error == null)
              _filteredRecords.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState(isDark))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final record = _filteredRecords[index];
                          return _AttendanceRecordCard(
                            record: record,
                            isDark: isDark,
                          );
                        },
                        childCount: _filteredRecords.length,
                      ),
                    ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDark ? AppColors.error : AppColorsLight.error,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            _error!,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(bool isDark) {
    final totalDays = _attendanceStats['total_days'] ?? 0;
    final presentDays = _attendanceStats['present_days'] ?? 0;
    final absentDays = _attendanceStats['absent_days'] ?? 0;
    final attendanceRate = (_attendanceStats['attendance_rate'] ?? 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
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
                    backgroundColor: isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getAttendanceColor(attendanceRate, isDark),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${attendanceRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Total Days',
                  value: totalDays.toString(),
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                  isDark: isDark,
                ),
                _StatItem(
                  label: 'Present',
                  value: presentDays.toString(),
                  color: isDark ? AppColors.success : AppColorsLight.success,
                  isDark: isDark,
                ),
                _StatItem(
                  label: 'Absent',
                  value: absentDays.toString(),
                  color: isDark ? AppColors.error : AppColorsLight.error,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(bool isDark) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final currentMonth = _selectedMonth ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: GestureDetector(
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
                  _loadData();
                },
              ),
              Text(
                '${months[currentMonth.month - 1]} ${currentMonth.year}',
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
                  if (currentMonth.year < now.year ||
                      (currentMonth.year == now.year && currentMonth.month < now.month)) {
                    setState(() {
                      _selectedMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                    });
                    _loadData();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
      _loadData();
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

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'No attendance records found',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            _selectedFilter == 'all'
                ? 'Your attendance will appear here once recorded'
                : 'No $_selectedFilter records for this month',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
  final Map<String, dynamic> record;
  final bool isDark;

  const _AttendanceRecordCard({
    required this.record,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final status = record['status']?.toString() ?? 'unknown';
    final date = record['date']?.toString() ?? '';
    final batchName = record['batch_name']?.toString() ?? 'Unknown Batch';
    final remarks = record['remarks']?.toString() ?? '';

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
                    _formatDate(date),
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
