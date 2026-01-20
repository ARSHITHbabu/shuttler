import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/forms/add_student_dialog.dart';
import '../../widgets/forms/add_coach_dialog.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/batch_provider.dart';
import '../../models/batch_attendance.dart';
import 'students_screen.dart';
import 'coaches_screen.dart';
import 'fees_screen.dart';

/// Home Screen - Dashboard overview
/// Matches React reference: HomeScreen.tsx
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _showAttendanceDetailsDialog(
    BuildContext context,
    AsyncValue<List<BatchAttendance>> finishedBatchesAsync,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackgroundColor,
        title: Text(
          'Today\'s Batch Attendance',
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: finishedBatchesAsync.when(
            data: (batches) {
              if (batches.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingM),
                  child: Builder(
                    builder: (context) => Text(
                      'No batches have finished today yet.',
                      style: TextStyle(color: context.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: batches.map((batch) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          boxShadow: NeumorphicStyles.getSmallInsetShadow(),
                        ),
                        child: Builder(
                          builder: (context) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                batch.batchName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingS),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    batch.timing,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${batch.attendanceRate.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: batch.attendanceRate >= 80
                                          ? context.successColor
                                          : batch.attendanceRate >= 60
                                              ? Colors.orange
                                              : context.errorColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.spacingS),
                              Container(
                                width: double.infinity,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: context.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (batch.attendanceRate / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: batch.attendanceRate >= 80
                                          ? context.successColor
                                          : batch.attendanceRate >= 60
                                              ? Colors.orange
                                              : context.errorColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const DashboardSkeleton(),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Builder(
                builder: (context) => Text(
                  'Error loading attendance: ${error.toString()}',
                  style: TextStyle(color: context.errorColor),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Builder(
              builder: (context) => Text(
                'Close',
                style: TextStyle(color: context.textPrimaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final upcomingBatchesAsync = ref.watch(upcomingBatchesProvider);
    final finishedBatchesAsync = ref.watch(finishedBatchesWithAttendanceProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dashboardStatsProvider.notifier).refresh();
        ref.invalidate(upcomingBatchesProvider);
        ref.invalidate(finishedBatchesWithAttendanceProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ace Badminton Academy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(),
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          statsAsync.when(
            data: (stats) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppDimensions.spacingM,
                mainAxisSpacing: AppDimensions.spacingM,
                childAspectRatio: 0.85,
                children: [
                  _StatCard(
                    icon: Icons.people_outline,
                    value: stats.totalStudents.toString(),
                    label: 'Total Students',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StudentsScreen(),
                        ),
                      );
                    },
                  ),
                  _StatCard(
                    icon: Icons.person_outline,
                    value: stats.totalCoaches.toString(),
                    label: 'Total Coaches',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CoachesScreen(),
                        ),
                      );
                    },
                  ),
                  _StatCard(
                    icon: Icons.calendar_today_outlined,
                    value: stats.activeBatches.toString(),
                    label: 'Active Batches',
                    onTap: null,
                  ),
                  _StatCard(
                    icon: Icons.attach_money_outlined,
                    value: '₹${_formatCurrency(stats.pendingFees)}',
                    label: 'Pending Fees',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FeesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: GridSkeleton(itemCount: 4, crossAxisCount: 2),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: ErrorDisplay(
                message: 'Failed to load statistics',
                onRetry: () => ref.read(dashboardStatsProvider.notifier).refresh(),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Today's Insights
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Insights",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                statsAsync.when(
                  data: (stats) => GestureDetector(
                    onTap: () => _showAttendanceDetailsDialog(context, finishedBatchesAsync),
                    child: NeumorphicContainer(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: context.backgroundColor,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                  boxShadow: NeumorphicStyles.getInsetShadow(),
                                ),
                                child: Icon(
                                  Icons.trending_up,
                                  size: 20,
                                  color: context.iconPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attendance Rate',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.textSecondaryColor,
                                      ),
                                    ),
                                    Text(
                                      '${stats.todayAttendanceRate.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: context.textSecondaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          Container(
                            width: double.infinity,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: NeumorphicStyles.getSmallInsetShadow(),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (stats.todayAttendanceRate / 100).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF505050),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(height: 80, child: Center(child: ListSkeleton(itemCount: 1))),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                upcomingBatchesAsync.when(
                  data: (batches) => NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Batches',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        if (batches.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(AppDimensions.spacingM),
                            child: Builder(
                              builder: (context) => Text(
                                'No upcoming batches today',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ),
                          )
                        else
                          ...batches.asMap().entries.map((entry) {
                            final batch = entry.value;
                            final isLast = entry.key == batches.length - 1;
                            return Column(
                              children: [
                                _UpcomingBatchItem(
                                  name: batch.name,
                                  time: batch.timeRange,
                                  batchId: batch.id,
                                ),
                                if (!isLast) const SizedBox(height: AppDimensions.spacingS),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
                  loading: () => const NeumorphicContainer(
                    padding: EdgeInsets.all(AppDimensions.paddingM),
                    child: ListSkeleton(itemCount: 3),
                  ),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.add,
                        label: 'Add Student',
                        onTap: () => _showAddStudentDialog(context),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.add,
                        label: 'Invite Coach',
                        onTap: () => _showAddCoachDialog(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddStudentDialog(),
    );
  }

  void _showAddCoachDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCoachDialog(
        onSubmit: (coachData) async {
          // Dialog handles invitation internally, just refresh the dashboard
          ref.invalidate(dashboardStatsProvider);
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  boxShadow: NeumorphicStyles.getInsetShadow(),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: context.iconPrimaryColor,
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: context.textTertiaryColor,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondaryColor,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return onTap != null
        ? GestureDetector(
            onTap: onTap,
            child: card,
          )
        : card;
  }
}

class _UpcomingBatchItem extends ConsumerWidget {
  final String name;
  final String time;
  final int batchId;

  const _UpcomingBatchItem({
    required this.name,
    required this.time,
    required this.batchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchStudentsAsync = ref.watch(batchStudentsProvider(batchId));
    
    return batchStudentsAsync.when(
      data: (students) {
        final studentCount = students.length;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                boxShadow: NeumorphicStyles.getSmallInsetShadow(),
              ),
              child: Text(
                '$studentCount ${studentCount == 1 ? 'student' : 'students'}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.iconPrimaryColor,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textPrimaryColor,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 60,
            height: 20,
            child: Center(child: ListSkeleton(itemCount: 1)),
          ),
        ],
      ),
      error: (error, stack) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textPrimaryColor,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) => Text(
              '0 students',
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: context.iconPrimaryColor,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
