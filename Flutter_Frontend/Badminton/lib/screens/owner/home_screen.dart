import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/forms/add_student_dialog.dart';
import '../../widgets/forms/add_coach_dialog.dart';
import '../../providers/dashboard_provider.dart';
import 'students_screen.dart';
import 'coaches_screen.dart';
import 'fees_screen.dart';
import '../../providers/owner_navigation_provider.dart';
import '../../core/utils/canadian_holidays.dart';
import '../../providers/owner_provider.dart';

/// Home Screen - Dashboard overview
/// Matches React reference: HomeScreen.tsx
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dashboardStatsProvider.notifier).refresh();
        ref.invalidate(ownerUpcomingSessionsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
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
                ref.watch(activeOwnerProvider).when(
                      data: (owner) => Text(
                        owner?.academyName ?? 'Pursue Badminton',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      loading: () => Container(
                        height: 28,
                        width: 150,
                        decoration: BoxDecoration(
                          color: context.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      error: (_, __) => Text(
                        'Pursue Badminton',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
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
                // Holiday Indicator
                if (CanadianHolidays.isHoliday(DateTime.now())) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: context.errorColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.celebration, size: 16, color: context.errorColor),
                        const SizedBox(width: 8),
                        Text(
                          CanadianHolidays.getHolidayName(DateTime.now())!,
                          style: TextStyle(
                            color: context.errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Stats Grid
          statsAsync.when(
            data: (stats) => Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
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
                    label: 'Active Students',
                    isSmallScreen: isSmallScreen,
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
                    isSmallScreen: isSmallScreen,
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
                    isSmallScreen: isSmallScreen,
                    onTap: () {
                      ref.read(ownerBottomNavIndexProvider.notifier).state = 1; // 1 is Batches screen index
                    },
                  ),
                  _StatCard(
                    icon: Icons.attach_money_outlined,
                    value: '\$${_formatCurrency(stats.pendingFees)}',
                    label: 'Pending Fees',
                    isSmallScreen: isSmallScreen,
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

          // Upcoming Sessions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Sessions',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                ref.watch(ownerUpcomingSessionsProvider).when(
                      data: (sessions) => NeumorphicContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: sessions.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(AppDimensions.spacingM),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_available,
                                        size: 48,
                                        color: context.textTertiaryColor,
                                      ),
                                      const SizedBox(height: AppDimensions.spacingM),
                                      Text(
                                        'No upcoming sessions',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: context.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: sessions.asMap().entries.map((entry) {
                                  final session = entry.value;
                                  final isLast = entry.key == sessions.length - 1;
                                  return Column(
                                    children: [
                                      _UpcomingSessionItem(
                                        name: session['batch_name'] ?? 'Unknown Batch',
                                        time: session['time'] ?? '',
                                        location: session['location'] ?? '',
                                        date: session['date'] != null 
                                          ? _formatSessionDate(DateTime.parse(session['date']))
                                          : null,
                                      ),
                                      if (!isLast)
                                        Divider(
                                          color: context.surfaceLightColor,
                                          height: AppDimensions.spacingL,
                                        ),
                                    ],
                                  );
                                }).toList(),
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
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
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
                        isSmallScreen: isSmallScreen,
                        onTap: () => _showAddStudentDialog(context),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.add,
                        label: 'Invite Coach',
                        isSmallScreen: isSmallScreen,
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

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) return 'Today';
    if (sessionDate == tomorrow) return 'Tomorrow';
    
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
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
  final bool isSmallScreen;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
    this.isSmallScreen = false,
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
                width: isSmallScreen ? 32 : 40,
                height: isSmallScreen ? 32 : 40,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  boxShadow: NeumorphicStyles.getInsetShadow(),
                ),
                child: Icon(
                  icon,
                  size: isSmallScreen ? 16 : 20,
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
                fontSize: isSmallScreen ? 18 : 22,
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

class _UpcomingSessionItem extends StatelessWidget {
  final String name;
  final String time;
  final String location;
  final String? date;

  const _UpcomingSessionItem({
    required this.name,
    required this.time,
    required this.location,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            Icons.sports_tennis,
            size: 20,
            color: context.accentColor,
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
                      fontWeight: FontWeight.w500,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  if (date != null)
                    Text(
                      date!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.accentColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondaryColor,
                ),
              ),
              if (location.isNotEmpty)
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textTertiaryColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSmallScreen = false,
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
              size: isSmallScreen ? 20 : 24,
              color: context.iconPrimaryColor,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
