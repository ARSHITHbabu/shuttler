import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';

/// Student Schedule Screen - READ-ONLY view of session schedules
/// Students can view their batch schedules and upcoming sessions
class StudentScheduleScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentScheduleScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends ConsumerState<StudentScheduleScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _batches = [];
  String? _error;
  String? _selectedBatchId;
  DateTime _selectedDate = DateTime.now();

  // Calendar view mode
  bool _showCalendarView = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user ID from auth provider (preferred) or storage (fallback)
      int? userId;
      
      // Try to get from auth provider first
      final authStateAsync = ref.read(authProvider);
      final authState = authStateAsync.value;
      
      if (authState is Authenticated) {
        userId = authState.userId;
      }
      
      // Fallback: try to get from storage if auth provider doesn't have it
      if (userId == null) {
        final storageService = ref.read(storageServiceProvider);
        
        // Ensure storage is initialized
        if (!storageService.isInitialized) {
          await storageService.init();
        }
        
        userId = storageService.getUserId();
      }
      
      if (userId == null) {
        throw Exception('User not logged in. Please try logging in again.');
      }

      final apiService = ref.read(apiServiceProvider);

      // Load student's batches
      try {
        final batchesResponse = await apiService.get('/api/students/$userId/batches');
        if (batchesResponse.statusCode == 200) {
          _batches = List<Map<String, dynamic>>.from(batchesResponse.data['batches'] ?? batchesResponse.data ?? []);
        }
      } catch (e) {
        _batches = [];
      }

      // Load schedules
      try {
        final response = await apiService.get('/api/students/$userId/schedule');
        if (response.statusCode == 200) {
          _schedules = List<Map<String, dynamic>>.from(response.data['schedules'] ?? []);
        }
      } catch (e) {
        _schedules = [];
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

  List<Map<String, dynamic>> get _filteredSchedules {
    var filtered = _schedules;

    // Filter by batch
    if (_selectedBatchId != null) {
      filtered = filtered.where((s) => s['batch_id']?.toString() == _selectedBatchId).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> _getSchedulesForDay(DateTime date) {
    final dayName = _getDayName(date.weekday);
    return _filteredSchedules.where((schedule) {
      final daysOfWeek = schedule['days_of_week']?.toString() ?? '';
      return daysOfWeek.toLowerCase().contains(dayName.toLowerCase());
    }).toList();
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
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
              leading: widget.onBack != null
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                      onPressed: widget.onBack,
                    )
                  : null,
              title: Text(
                'My Schedule',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    _showCalendarView ? Icons.view_list : Icons.calendar_month,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                  onPressed: () {
                    setState(() {
                      _showCalendarView = !_showCalendarView;
                    });
                  },
                ),
              ],
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
                            // Batch Filter
                            if (_batches.isNotEmpty) ...[
                              _buildBatchFilter(isDark),
                              const SizedBox(height: AppDimensions.spacingM),
                            ],

                            // Calendar or List View
                            if (_showCalendarView)
                              _buildCalendarView(isDark)
                            else
                              _buildListView(isDark),
                          ],
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

  Widget _buildBatchFilter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All Batches',
              isSelected: _selectedBatchId == null,
              isDark: isDark,
              onTap: () => setState(() => _selectedBatchId = null),
            ),
            ..._batches.map((batch) {
              final batchId = batch['id']?.toString() ?? batch['batch_id']?.toString();
              final batchName = batch['batch_name']?.toString() ?? batch['name']?.toString() ?? 'Batch';
              return Padding(
                padding: const EdgeInsets.only(left: AppDimensions.spacingS),
                child: _FilterChip(
                  label: batchName,
                  isSelected: _selectedBatchId == batchId,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedBatchId = batchId),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(bool isDark) {
    return Column(
      children: [
        // Week Navigation
        _buildWeekNavigation(isDark),

        const SizedBox(height: AppDimensions.spacingM),

        // Week Days
        _buildWeekDays(isDark),

        const SizedBox(height: AppDimensions.spacingL),

        // Selected Day Sessions
        _buildSelectedDaySessions(isDark),
      ],
    );
  }

  Widget _buildWeekNavigation(bool isDark) {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
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
                  _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                });
              },
            ),
            Column(
              children: [
                Text(
                  '${months[startOfWeek.month - 1]} ${startOfWeek.day} - ${months[endOfWeek.month - 1]} ${endOfWeek.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                Text(
                  startOfWeek.year.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
              ),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 7));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDays(bool isDark) {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final isToday = date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year;
          final hasSession = _getSchedulesForDay(date).isNotEmpty;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.accent : AppColorsLight.accent)
                    : isToday
                        ? (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.2)
                        : null,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasSession)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.success : AppColorsLight.success),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedDaySessions(bool isDark) {
    final sessions = _getSchedulesForDay(_selectedDate);
    final dayName = _getDayName(_selectedDate.weekday);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dayName Sessions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),

          if (sessions.isEmpty)
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'No sessions scheduled',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...sessions.map((session) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                  child: _ScheduleCard(
                    schedule: session,
                    isDark: isDark,
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildListView(bool isDark) {
    if (_filteredSchedules.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),

          ..._filteredSchedules.map((schedule) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                child: _ScheduleCard(
                  schedule: schedule,
                  isDark: isDark,
                  showDays: true,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingXxl),
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'No schedule available',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'You need to be assigned to a batch first',
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.accent : AppColorsLight.accent)
              : (isDark ? AppColors.cardBackground : AppColorsLight.cardBackground),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: isSelected ? null : NeumorphicStyles.getElevatedShadow(),
        ),
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
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final bool isDark;
  final bool showDays;

  const _ScheduleCard({
    required this.schedule,
    required this.isDark,
    this.showDays = false,
  });

  @override
  Widget build(BuildContext context) {
    final batchName = schedule['batch_name']?.toString() ?? 'Training Session';
    final startTime = schedule['start_time']?.toString() ?? '';
    final endTime = schedule['end_time']?.toString() ?? '';
    final location = schedule['location']?.toString() ?? '';
    final activityType = schedule['activity_type']?.toString() ?? 'Training';
    final daysOfWeek = schedule['days_of_week']?.toString() ?? '';
    final notes = schedule['notes']?.toString() ?? '';
    final coachName = schedule['coach_name']?.toString() ?? '';

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  Icons.sports_tennis,
                  size: 24,
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batchName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      activityType,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Details
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColorsLight.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              boxShadow: NeumorphicStyles.getSmallInsetShadow(),
            ),
            child: Column(
              children: [
                if (showDays && daysOfWeek.isNotEmpty) ...[
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Days',
                    value: daysOfWeek,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                ],
                if (startTime.isNotEmpty) ...[
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: endTime.isNotEmpty ? '$startTime - $endTime' : startTime,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                ],
                if (location.isNotEmpty)
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: location,
                    isDark: isDark,
                  ),
                if (coachName.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  _DetailRow(
                    icon: Icons.person,
                    label: 'Coach',
                    value: coachName,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),

          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes,
                  size: 14,
                  color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    notes,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
