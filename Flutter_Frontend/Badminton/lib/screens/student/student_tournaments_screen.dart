import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/tournament_provider.dart';
import '../../models/tournament.dart';

/// Student Tournaments Screen - View tournament information
/// READ-ONLY view of all tournaments
class StudentTournamentsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentTournamentsScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentTournamentsScreen> createState() => _StudentTournamentsScreenState();
}

class _StudentTournamentsScreenState extends ConsumerState<StudentTournamentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Tournament> _filterTournaments(List<Tournament> tournaments, bool upcoming) {
    var filtered = tournaments.where((t) => upcoming ? t.isUpcoming : t.isPast).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.name.toLowerCase().contains(query) ||
            (t.location.toLowerCase().contains(query)) ||
            (t.description?.toLowerCase().contains(query) ?? false) ||
            (t.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort by date
    filtered.sort((a, b) => upcoming 
        ? a.date.compareTo(b.date) 
        : b.date.compareTo(a.date));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tournamentsAsync = ref.watch(tournamentListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(tournamentListProvider);
        },
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
                'Tournaments',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: tournamentsAsync.when(
                  data: (tournaments) => [
                    Tab(
                      child: Text('Upcoming (${tournaments.where((t) => t.isUpcoming).length})'),
                    ),
                    Tab(
                      child: Text('Past (${tournaments.where((t) => t.isPast).length})'),
                    ),
                  ],
                  loading: () => const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                  ],
                  error: (_, __) => const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tournaments...',
                      hintStyle: TextStyle(
                        color: isDark 
                            ? AppColors.textSecondary 
                            : AppColorsLight.textSecondary,
                      ),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: isDark 
                            ? AppColors.textSecondary 
                            : AppColorsLight.textSecondary,
                      ),
                    ),
                    style: TextStyle(
                      color: isDark 
                          ? AppColors.textPrimary 
                          : AppColorsLight.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: tournamentsAsync.when(
                  loading: () => const Center(child: ListSkeleton(itemCount: 5)),
                  error: (error, stack) => ErrorDisplay(
                    message: 'Failed to load tournaments: ${error.toString()}',
                    onRetry: () => ref.invalidate(tournamentListProvider),
                  ),
                  data: (tournaments) => TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTournamentList(
                        _filterTournaments(tournaments, true),
                        'No upcoming tournaments',
                        isDark,
                      ),
                      _buildTournamentList(
                        _filterTournaments(tournaments, false),
                        'No past tournaments',
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentList(List<Tournament> tournaments, String emptyMessage, bool isDark) {
    if (tournaments.isEmpty) {
      return Center(
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                emptyMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark 
                      ? AppColors.textSecondary 
                      : AppColorsLight.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
          child: _TournamentCard(tournament: tournament, isDark: isDark),
        );
      },
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final bool isDark;

  const _TournamentCard({required this.tournament, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 24,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark 
                            ? AppColors.textPrimary 
                            : AppColorsLight.textPrimary,
                      ),
                    ),
                    if (tournament.category != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        tournament.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark 
                              ? AppColors.textSecondary 
                              : AppColorsLight.textSecondary,
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
                  color: tournament.isUpcoming 
                      ? AppColors.success 
                      : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  tournament.isUpcoming ? 'Upcoming' : 'Past',
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
                color: isDark 
                    ? AppColors.textSecondary 
                    : AppColorsLight.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM, yyyy').format(tournament.date),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark 
                      ? AppColors.textSecondary 
                      : AppColorsLight.textSecondary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark 
                    ? AppColors.textSecondary 
                    : AppColorsLight.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  tournament.location,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark 
                        ? AppColors.textSecondary 
                        : AppColorsLight.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (tournament.description != null && tournament.description!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              tournament.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark 
                    ? AppColors.textSecondary 
                    : AppColorsLight.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
