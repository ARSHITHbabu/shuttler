import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/schedule.dart';

/// Coach Schedule Screen - View sessions calendar
class CoachScheduleScreen extends ConsumerStatefulWidget {
  const CoachScheduleScreen({super.key});

  @override
  ConsumerState<CoachScheduleScreen> createState() => _CoachScheduleScreenState();
}

class _CoachScheduleScreenState extends ConsumerState<CoachScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Schedule')),
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
        appBar: AppBar(title: const Text('Schedule')),
        body: const Center(child: DashboardSkeleton()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
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
    final scheduleAsync = ref.watch(coachScheduleProvider(coachId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: scheduleAsync.when(
                data: (sessions) {
                  final upcoming = sessions.where((s) => !s.isPast).toList();
                  return Text('Upcoming (${upcoming.length})');
                },
                loading: () => const Text('Upcoming'),
                error: (_, __) => const Text('Upcoming'),
              ),
            ),
            Tab(
              child: scheduleAsync.when(
                data: (sessions) {
                  final past = sessions.where((s) => s.isPast).toList();
                  return Text('Past (${past.length})');
                },
                loading: () => const Text('Past'),
                error: (_, __) => const Text('Past'),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(coachScheduleProvider(coachId));
        },
        child: scheduleAsync.when(
          data: (sessions) {
            final upcoming = sessions.where((s) => !s.isPast).toList();
            final past = sessions.where((s) => s.isPast).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildSessionList(upcoming, 'No upcoming sessions'),
                _buildSessionList(past, 'No past sessions'),
              ],
            );
          },
          loading: () => const Center(child: ListSkeleton(itemCount: 5)),
          error: (error, stack) => ErrorDisplay(
            message: 'Failed to load schedule',
            onRetry: () => ref.invalidate(coachScheduleProvider(coachId)),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionList(List<Schedule> sessions, String emptyMessage) {
    if (sessions.isEmpty) {
      return Center(
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
          child: _SessionCard(session: session),
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Schedule session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    // Session type color
    Color typeColor = AppColors.accent;
    String typeLabel = session.sessionType.toUpperCase();
    IconData typeIcon = Icons.sports_outlined;
    
    if (session.sessionType.toLowerCase() == 'tournament') {
      typeColor = AppColors.warning;
      typeIcon = Icons.emoji_events_outlined;
    } else if (session.sessionType.toLowerCase() == 'camp') {
      typeColor = AppColors.success;
      typeIcon = Icons.event_outlined;
    }

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(
                  typeIcon,
                  size: 20,
                  color: typeColor,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (session.batchName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        session.batchName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM, yyyy').format(session.date),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (session.startTime != null) ...[
                const SizedBox(width: AppDimensions.spacingM),
                Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${session.startTime}${session.endTime != null ? ' - ${session.endTime}' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (session.location != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.location!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (session.description != null && session.description!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              session.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
