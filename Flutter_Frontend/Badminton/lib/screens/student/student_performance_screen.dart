import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/performance_provider.dart';
import '../../models/performance.dart';

/// Student Performance Screen - READ-ONLY view of performance records
/// Students can view their skill ratings and progress but cannot edit
class StudentPerformanceScreen extends ConsumerStatefulWidget {
  const StudentPerformanceScreen({super.key});

  @override
  ConsumerState<StudentPerformanceScreen> createState() => _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends ConsumerState<StudentPerformanceScreen> {
  // Filter options
  String _selectionMode = 'all'; // 'date', 'month', 'year', 'all'
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
              message: 'Please log in to view performance records',
              onRetry: () => ref.invalidate(authProvider),
            ),
          );
        }

        final userId = authState.userId;
        
        // Determine date range based on selection mode
        DateTime? startDate;
        DateTime? endDate;
        
        if (_selectionMode == 'date' && _selectedDate != null) {
          // Single date selection
          startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
          endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
        } else if (_selectionMode == 'month' && _selectedMonth != null) {
          // Month selection
          startDate = DateTime(_selectedMonth!.year, _selectedMonth!.month, 1);
          endDate = DateTime(_selectedMonth!.year, _selectedMonth!.month + 1, 0, 23, 59, 59);
        } else if (_selectionMode == 'year' && _selectedYear != null) {
          // Year selection
          startDate = DateTime(_selectedYear!, 1, 1);
          endDate = DateTime(_selectedYear!, 12, 31, 23, 59, 59);
        }
        // If 'all', startDate and endDate remain null
        
        final performanceAsync = ref.watch(performanceByStudentProvider(
          userId,
          startDate: startDate,
          endDate: endDate,
        ));

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () async {
              DateTime? startDate;
              DateTime? endDate;
              
              if (_selectionMode == 'date' && _selectedDate != null) {
                startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
              } else if (_selectionMode == 'month' && _selectedMonth != null) {
                startDate = DateTime(_selectedMonth!.year, _selectedMonth!.month, 1);
                endDate = DateTime(_selectedMonth!.year, _selectedMonth!.month + 1, 0, 23, 59, 59);
              } else if (_selectionMode == 'year' && _selectedYear != null) {
                startDate = DateTime(_selectedYear!, 1, 1);
                endDate = DateTime(_selectedYear!, 12, 31, 23, 59, 59);
              }
              
              ref.invalidate(performanceByStudentProvider(
                userId,
                startDate: startDate,
                endDate: endDate,
              ));
              ref.invalidate(averagePerformanceProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: Text(
                    'My Performance',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                ),

                // Content
                SliverToBoxAdapter(
                  child: performanceAsync.when(
                    loading: () => const SizedBox(
                      height: 400,
                      child: ListSkeleton(itemCount: 3),
                    ),
                    error: (error, stack) => ErrorDisplay(
                      message: 'Failed to load performance records: ${error.toString()}',
                      onRetry: () {
                        DateTime? startDate;
                        DateTime? endDate;
                        
                        if (_selectionMode == 'date' && _selectedDate != null) {
                          startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                          endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
                        } else if (_selectionMode == 'month' && _selectedMonth != null) {
                          startDate = DateTime(_selectedMonth!.year, _selectedMonth!.month, 1);
                          endDate = DateTime(_selectedMonth!.year, _selectedMonth!.month + 1, 0, 23, 59, 59);
                        } else if (_selectionMode == 'year' && _selectedYear != null) {
                          startDate = DateTime(_selectedYear!, 1, 1);
                          endDate = DateTime(_selectedYear!, 12, 31, 23, 59, 59);
                        }
                        
                        ref.invalidate(performanceByStudentProvider(
                          userId,
                          startDate: startDate,
                          endDate: endDate,
                        ));
                      },
                    ),
                    data: (performanceRecords) {
                      if (performanceRecords.isEmpty) {
                        return Column(
                          children: [
                            _buildDateSelector(isDark, userId),
                            const SizedBox(height: AppDimensions.spacingL),
                            EmptyState.noPerformance(),
                          ],
                        );
                      }

                      // Calculate averages from filtered records
                      final overallStats = _calculateOverallStats(performanceRecords);

                      // Sort by date descending (latest first)
                      final sortedRecords = List<Performance>.from(performanceRecords)
                        ..sort((a, b) => b.date.compareTo(a.date));

                      return Column(
                        children: [
                          // Overall Performance Overview (based on filtered records)
                          _buildOverallPerformance(isDark, overallStats),

                          const SizedBox(height: AppDimensions.spacingL),

                          // Progress Chart
                          if (sortedRecords.length >= 2)
                            _buildProgressChart(isDark, sortedRecords),

                          if (sortedRecords.length >= 2)
                            const SizedBox(height: AppDimensions.spacingL),

                          // Overall Skill Breakdown (based on filtered records)
                          _buildOverallSkillBreakdown(isDark, overallStats),

                          const SizedBox(height: AppDimensions.spacingL),

                          // Date Selector
                          _buildDateSelector(isDark, userId),

                          const SizedBox(height: AppDimensions.spacingM),

                          // Performance History Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Performance History',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${sortedRecords.length} records',
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
                  ),
                ),

                // Performance Records List
                performanceAsync.when(
                  loading: () => const SliverToBoxAdapter(child: SizedBox()),
                  error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                  data: (performanceRecords) {
                    if (performanceRecords.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox());
                    }

                    // Sort by date descending (latest first)
                    final sortedRecords = List<Performance>.from(performanceRecords)
                      ..sort((a, b) => b.date.compareTo(a.date));

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final record = sortedRecords[index];
                          return _PerformanceRecordCard(
                            record: record,
                            isDark: isDark,
                          );
                        },
                        childCount: sortedRecords.length,
                      ),
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

  Widget _buildOverallPerformance(bool isDark, Map<String, dynamic> overallStats) {
    final avgScore = (overallStats['average'] ?? 0.0).toDouble();
    final totalRecords = (overallStats['totalRecords'] ?? 0) as int;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            Text(
              'Overall Performance Record',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Score Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: (avgScore / 5).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(avgScore, isDark),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      avgScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      '/ 5.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingM),

            Text(
              'Based on $totalRecords ${totalRecords == 1 ? 'record' : 'records'}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSkillBreakdown(bool isDark, Map<String, dynamic> overallStats) {
    final skills = [
      {'name': 'Serve', 'rating': (overallStats['serve'] ?? 0.0).toDouble(), 'icon': Icons.sports_tennis},
      {'name': 'Smash', 'rating': (overallStats['smash'] ?? 0.0).toDouble(), 'icon': Icons.bolt},
      {'name': 'Footwork', 'rating': (overallStats['footwork'] ?? 0.0).toDouble(), 'icon': Icons.directions_run},
      {'name': 'Defense', 'rating': (overallStats['defense'] ?? 0.0).toDouble(), 'icon': Icons.shield},
      {'name': 'Stamina', 'rating': (overallStats['stamina'] ?? 0.0).toDouble(), 'icon': Icons.favorite},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skill Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: skills.map((skill) {
                final rating = (skill['rating'] as double);
                return _SkillBar(
                  name: skill['name'] as String,
                  rating: rating,
                  icon: skill['icon'] as IconData,
                  isDark: isDark,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshPerformanceData(int userId) {
    DateTime? startDate;
    DateTime? endDate;
    
    if (_selectionMode == 'date' && _selectedDate != null) {
      startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
    } else if (_selectionMode == 'month' && _selectedMonth != null) {
      startDate = DateTime(_selectedMonth!.year, _selectedMonth!.month, 1);
      endDate = DateTime(_selectedMonth!.year, _selectedMonth!.month + 1, 0, 23, 59, 59);
    } else if (_selectionMode == 'year' && _selectedYear != null) {
      startDate = DateTime(_selectedYear!, 1, 1);
      endDate = DateTime(_selectedYear!, 12, 31, 23, 59, 59);
    }
    
    ref.invalidate(performanceByStudentProvider(
      userId,
      startDate: startDate,
      endDate: endDate,
    ));
  }

  Map<String, dynamic> _calculateOverallStats(List<Performance> records) {
    if (records.isEmpty) {
      return {
        'average': 0.0,
        'serve': 0.0,
        'smash': 0.0,
        'footwork': 0.0,
        'defense': 0.0,
        'stamina': 0.0,
        'totalRecords': 0,
      };
    }

    final serveAvg = records.map((r) => r.serve).reduce((a, b) => a + b) / records.length;
    final smashAvg = records.map((r) => r.smash).reduce((a, b) => a + b) / records.length;
    final footworkAvg = records.map((r) => r.footwork).reduce((a, b) => a + b) / records.length;
    final defenseAvg = records.map((r) => r.defense).reduce((a, b) => a + b) / records.length;
    final staminaAvg = records.map((r) => r.stamina).reduce((a, b) => a + b) / records.length;
    final overallAvg = (serveAvg + smashAvg + footworkAvg + defenseAvg + staminaAvg) / 5.0;

    return {
      'average': overallAvg,
      'serve': serveAvg,
      'smash': smashAvg,
      'footwork': footworkAvg,
      'defense': defenseAvg,
      'stamina': staminaAvg,
      'totalRecords': records.length,
    };
  }

  Color _getScoreColor(double score, bool isDark) {
    if (score >= 4) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (score >= 3) {
      return isDark ? AppColors.accent : AppColorsLight.accent;
    } else if (score >= 2) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }

  Widget _buildDateSelector(bool isDark, int userId) {
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
                  onTap: () {
                    setState(() {
                      _selectionMode = 'date';
                    });
                    _refreshPerformanceData(userId);
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _SelectionModeTab(
                  label: 'Month',
                  isSelected: _selectionMode == 'month',
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _selectionMode = 'month';
                    });
                    _refreshPerformanceData(userId);
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _SelectionModeTab(
                  label: 'Year',
                  isSelected: _selectionMode == 'year',
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _selectionMode = 'year';
                    });
                    _refreshPerformanceData(userId);
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _SelectionModeTab(
                  label: 'All',
                  isSelected: _selectionMode == 'all',
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _selectionMode = 'all';
                    });
                    _refreshPerformanceData(userId);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Date/Month/Year Display and Navigation
          _buildDateDisplay(isDark, userId),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(bool isDark, int userId) {
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
                  final newDate = date.subtract(const Duration(days: 1));
                  setState(() {
                    _selectedDate = newDate;
                  });
                  _refreshPerformanceData(userId);
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
                    _refreshPerformanceData(userId);
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
                    _refreshPerformanceData(userId);
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
                  _refreshPerformanceData(userId);
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
                    _refreshPerformanceData(userId);
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
            'All Performance Records',
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
      // Get userId to refresh provider
      final authState = ref.read(authProvider);
      authState.whenData((auth) {
        if (auth is Authenticated) {
          _refreshPerformanceData(auth.userId);
        }
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
      // Get userId to refresh provider
      final authState = ref.read(authProvider);
      authState.whenData((auth) {
        if (auth is Authenticated) {
          _refreshPerformanceData(auth.userId);
        }
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
      // Get userId to refresh provider
      final authState = ref.read(authProvider);
      authState.whenData((auth) {
        if (auth is Authenticated) {
          _refreshPerformanceData(auth.userId);
        }
      });
    }
  }

  Widget _buildProgressChart(bool isDark, List<Performance> performanceRecords) {
    // Sort by date ascending for chart
    final sortedHistory = List<Performance>.from(performanceRecords)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Prepare data for chart - average rating over time
    final spots = sortedHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.averageRating);
    }).toList();

    final textColor = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final accentColor = isDark ? AppColors.accent : AppColorsLight.accent;
    final bgColor = isDark ? AppColors.background : AppColorsLight.background;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: textColor.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedHistory.length) {
                            return const Text('');
                          }
                          final date = sortedHistory[value.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MMM dd').format(date),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: textColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  minX: 0,
                  maxX: (sortedHistory.length - 1).toDouble(),
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: accentColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: accentColor,
                            strokeWidth: 2,
                            strokeColor: bgColor,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: accentColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

class _SkillBar extends StatelessWidget {
  final String name;
  final double rating;
  final IconData icon;
  final bool isDark;

  const _SkillBar({
    required this.name,
    required this.rating,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColorsLight.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              boxShadow: NeumorphicStyles.getInsetShadow(),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      '${rating.toStringAsFixed(1)}/5',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getSkillColor(rating, isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.background : AppColorsLight.background,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: NeumorphicStyles.getSmallInsetShadow(),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (rating / 5).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getSkillColor(rating, isDark),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSkillColor(double rating, bool isDark) {
    if (rating >= 4) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (rating >= 3) {
      return isDark ? AppColors.accent : AppColorsLight.accent;
    } else if (rating >= 2) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }
}

class _PerformanceRecordCard extends StatelessWidget {
  final Performance record;
  final bool isDark;

  const _PerformanceRecordCard({
    required this.record,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final date = record.date;
    final comments = record.comments ?? '';
    final avgScore = record.averageRating;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingS,
      ),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date.toIso8601String()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(avgScore, isDark).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    '${avgScore.toStringAsFixed(1)}/5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getScoreColor(avgScore, isDark),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Mini Skill Ratings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniSkillRating(
                  label: 'Serve',
                  rating: record.serve.toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Smash',
                  rating: record.smash.toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Footwork',
                  rating: record.footwork.toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Defense',
                  rating: record.defense.toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Stamina',
                  rating: record.stamina.toDouble(),
                  isDark: isDark,
                ),
              ],
            ),

            if (comments.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.background : AppColorsLight.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  boxShadow: NeumorphicStyles.getSmallInsetShadow(),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Text(
                        comments,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Removed _calculateAverageScore - using Performance.averageRating instead

  Color _getScoreColor(double score, bool isDark) {
    if (score >= 4) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (score >= 3) {
      return isDark ? AppColors.accent : AppColorsLight.accent;
    } else if (score >= 2) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
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

class _MiniSkillRating extends StatelessWidget {
  final String label;
  final double rating;
  final bool isDark;

  const _MiniSkillRating({
    required this.label,
    required this.rating,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          rating.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getColor(rating, isDark),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
        ),
      ],
    );
  }

  Color _getColor(double rating, bool isDark) {
    if (rating >= 4) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (rating >= 3) {
      return isDark ? AppColors.accent : AppColorsLight.accent;
    } else if (rating >= 2) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }
}
