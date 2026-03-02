import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import '../../providers/coach_provider.dart';
import '../../providers/service_providers.dart';
import '../../models/batch.dart';
import '../../models/student.dart';
import '../owner/performance_tracking_screen.dart';

/// Coach Performance Screen — B8
/// Shows which students have/haven't been assessed for a given batch + date.
/// Coaches can tap "Add Entry" for pending students or "View/Edit" for assessed ones.
class CoachPerformanceScreen extends ConsumerStatefulWidget {
  const CoachPerformanceScreen({super.key});

  @override
  ConsumerState<CoachPerformanceScreen> createState() =>
      _CoachPerformanceScreenState();
}

class _CoachPerformanceScreenState
    extends ConsumerState<CoachPerformanceScreen> {
  DateTime _selectedDate = DateTime.now();
  Batch? _selectedBatch;
  List<Map<String, dynamic>> _completionStatus = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Load status after first frame so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStatus());
  }

  int? _coachId() {
    final auth = ref.read(authProvider).value;
    if (auth is Authenticated) return auth.userId;
    return null;
  }

  Future<void> _loadStatus() async {
    if (_selectedBatch == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final result = await performanceService.getCompletionStatus(
        batchId: _selectedBatch!.id,
        date: dateStr,
      );
      if (mounted) setState(() => _completionStatus = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: isDark ? AppColors.accent : AppColorsLight.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _loadStatus();
    }
  }

  void _navigateToEntry(Map<String, dynamic> entry, bool isDark) {
    final student = Student(
      id: entry['student_id'] as int,
      name: entry['student_name'] as String,
      phone: '',
      email: '',
      status: 'active',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PerformanceTrackingScreen(initialStudent: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final coachId = _coachId();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.background : AppColorsLight.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
        elevation: 0,
        title: Text(
          'Performance Tracking',
          style: TextStyle(
            color:
                isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
        ),
      ),
      body: coachId == null
          ? const Center(child: Text('Not authenticated'))
          : _buildBody(context, isDark, coachId),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, int coachId) {
    return Column(
      children: [
        _buildFilters(context, isDark, coachId),
        Expanded(child: _buildContent(isDark)),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, bool isDark, int coachId) {
    final batchesAsync = ref.watch(coachBatchesProvider(coachId));

    return Container(
      color: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // Batch selector
          batchesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(
              'Could not load batches',
              style: TextStyle(
                color: isDark ? AppColors.error : AppColorsLight.error,
              ),
            ),
            data: (batches) {
              if (batches.isEmpty) {
                return Text(
                  'No batches assigned to you.',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                );
              }
              // Auto-select first batch on first load
              if (_selectedBatch == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _selectedBatch == null) {
                    setState(() => _selectedBatch = batches.first);
                    _loadStatus();
                  }
                });
              }
              return DropdownButtonFormField<Batch>(
                value: _selectedBatch,
                dropdownColor: isDark
                    ? AppColors.cardBackground
                    : AppColorsLight.cardBackground,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColorsLight.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Select Batch',
                  labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.border
                          : AppColorsLight.border,
                    ),
                  ),
                ),
                items: batches
                    .map(
                      (b) => DropdownMenuItem(
                        value: b,
                        child: Text(b.batchName),
                      ),
                    )
                    .toList(),
                onChanged: (b) {
                  setState(() => _selectedBatch = b);
                  _loadStatus();
                },
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Date picker row
          GestureDetector(
            onTap: () => _pickDate(isDark),
            child: NeumorphicContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: isDark ? AppColors.accent : AppColorsLight.accent,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Text(
                    DateFormat('EEEE, d MMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_selectedBatch == null) {
      return Center(
        child: Text(
          'Select a batch to view completion status.',
          style: TextStyle(
            color:
                isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: isDark ? AppColors.error : AppColorsLight.error,
                  size: 48),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                'Error: $_error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.error : AppColorsLight.error,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              ElevatedButton(
                onPressed: _loadStatus,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_completionStatus.isEmpty) {
      return Center(
        child: Text(
          'No students enrolled in this batch.',
          style: TextStyle(
            color:
                isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
      );
    }

    final assessed = _completionStatus.where((e) => e['has_entry'] == true).length;
    final total = _completionStatus.length;

    return RefreshIndicator(
      onRefresh: _loadStatus,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          // Summary chip
          _SummaryBar(assessed: assessed, total: total, isDark: isDark),
          const SizedBox(height: AppDimensions.spacingM),
          ..._completionStatus.map(
            (entry) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.spacingS),
              child: _StudentStatusCard(
                entry: entry,
                isDark: isDark,
                onTap: () => _navigateToEntry(entry, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int assessed;
  final int total;
  final bool isDark;

  const _SummaryBar({
    required this.assessed,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : assessed / total;
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assessment Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColorsLight.textPrimary,
                ),
              ),
              Text(
                '$assessed / $total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          ClipRoundedRect(
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: isDark
                  ? AppColors.border
                  : AppColorsLight.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct == 1.0
                    ? Colors.green
                    : (isDark ? AppColors.accent : AppColorsLight.accent),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            pct == 1.0
                ? 'All students assessed!'
                : '${total - assessed} student(s) pending assessment',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ClipRoundedRect extends StatelessWidget {
  final Widget child;

  const ClipRoundedRect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: child,
    );
  }
}

class _StudentStatusCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isDark;
  final VoidCallback onTap;

  const _StudentStatusCard({
    required this.entry,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEntry = entry['has_entry'] == true;
    final name = entry['student_name'] as String? ?? 'Unknown';

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (hasEntry ? Colors.green : Colors.orange)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              hasEntry ? Icons.check_circle_outline : Icons.pending_outlined,
              color: hasEntry ? Colors.green : Colors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColorsLight.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasEntry ? 'Assessment recorded' : 'Not yet assessed',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasEntry
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          // Action button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (hasEntry ? AppColors.accent : Colors.orange)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              hasEntry ? 'View/Edit' : 'Add Entry',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasEntry
                    ? (isDark ? AppColors.accent : AppColorsLight.accent)
                    : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
