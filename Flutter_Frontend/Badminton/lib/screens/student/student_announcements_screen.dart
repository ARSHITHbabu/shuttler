import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/service_providers.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement.dart';

/// Student Announcements Screen - READ-ONLY view of academy announcements
/// Students can view announcements targeted to them or all students
class StudentAnnouncementsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentAnnouncementsScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentAnnouncementsScreen> createState() => _StudentAnnouncementsScreenState();
}

class _StudentAnnouncementsScreenState extends ConsumerState<StudentAnnouncementsScreen> {
  String _selectedFilter = 'all'; // 'all', 'urgent', 'high', 'normal', 'low'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Announcement> _filterAnnouncements(List<Announcement> announcements) {
    var filtered = announcements;

    // Filter by priority
    if (_selectedFilter != 'all') {
      filtered = filtered.where((a) {
        final priority = a.priority.toLowerCase();
        return priority == _selectedFilter;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((a) {
        return a.title.toLowerCase().contains(query) ||
            a.message.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by priority and date
    filtered.sort((a, b) {
      final priorityOrder = {'urgent': 0, 'high': 1, 'normal': 2, 'low': 3};
      final aPriority = priorityOrder[a.priority.toLowerCase()] ?? 2;
      final bPriority = priorityOrder[b.priority.toLowerCase()] ?? 2;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get announcements for students using provider
    final announcementsAsync = ref.watch(announcementByAudienceProvider('students'));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(announcementByAudienceProvider('students'));
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
                'Announcements',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),

            // Content
            SliverToBoxAdapter(
              child: announcementsAsync.when(
                loading: () => const SizedBox(
                  height: 400,
                  child: Center(child: ListSkeleton(itemCount: 5)),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: ErrorDisplay(
                    message: 'Failed to load announcements: ${error.toString()}',
                    onRetry: () => ref.invalidate(announcementByAudienceProvider('students')),
                  ),
                ),
                data: (announcements) {
                  final filtered = _filterAnnouncements(announcements);
                  final urgentCount = announcements.where((a) => a.priority.toLowerCase() == 'urgent' || a.priority.toLowerCase() == 'high').length;

                  return Column(
                    children: [
                      // Search Bar
                      _buildSearchBar(isDark),

                      const SizedBox(height: AppDimensions.spacingM),

                      // Filter Chips
                      _buildFilterChips(isDark),

                      const SizedBox(height: AppDimensions.spacingM),

                      // Announcement Count
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingL,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${filtered.length} announcements',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                              ),
                            ),
                            if (urgentCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDark ? AppColors.error : AppColorsLight.error).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      size: 14,
                                      color: isDark ? AppColors.error : AppColorsLight.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$urgentCount important',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.error : AppColorsLight.error,
                                      ),
                                    ),
                                  ],
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

            // Announcements List
            announcementsAsync.when(
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (announcements) {
                final filtered = _filterAnnouncements(announcements);
                return filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          child: EmptyState.noAnnouncements(),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final announcement = filtered[index];
                            return _AnnouncementCard(
                              announcement: announcement,
                              isDark: theme.brightness == Brightness.dark,
                              onTap: () => _showAnnouncementDetail(announcement, theme.brightness == Brightness.dark),
                            );
                          },
                          childCount: filtered.length,
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
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingXs,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search announcements...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textHint : AppColorsLight.textTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Icon(
                  Icons.close,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: _selectedFilter == 'all',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'all'),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _FilterChip(
              label: 'Important',
              isSelected: _selectedFilter == 'high',
              isDark: isDark,
              color: isDark ? AppColors.error : AppColorsLight.error,
              onTap: () => setState(() => _selectedFilter = 'high'),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _FilterChip(
              label: 'Normal',
              isSelected: _selectedFilter == 'normal',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'normal'),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _FilterChip(
              label: 'Low Priority',
              isSelected: _selectedFilter == 'low',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'low'),
            ),
          ],
        ),
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
            Icons.campaign_outlined,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            _searchQuery.isNotEmpty
                ? 'No announcements match your search'
                : _selectedFilter != 'all'
                    ? 'No $_selectedFilter priority announcements'
                    : 'No announcements yet',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Academy announcements will appear here',
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

  void _showAnnouncementDetail(Announcement announcement, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AnnouncementDetailSheet(
        announcement: announcement,
        isDark: isDark,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? (isDark ? AppColors.accent : AppColorsLight.accent);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
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

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final bool isDark;
  final VoidCallback onTap;

  const _AnnouncementCard({
    required this.announcement,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = announcement.title;
    final message = announcement.message;
    final priority = announcement.priority.toLowerCase();
    final createdAt = announcement.createdAt;
    final author = announcement.createdBy?.toString() ?? '';

    final isHighPriority = priority == 'urgent' || priority == 'high';

    Color priorityColor;
    IconData priorityIcon;

    switch (priority) {
      case 'high':
        priorityColor = isDark ? AppColors.error : AppColorsLight.error;
        priorityIcon = Icons.priority_high;
        break;
      case 'low':
        priorityColor = isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;
        priorityIcon = Icons.low_priority;
        break;
      default:
        priorityColor = isDark ? AppColors.accent : AppColorsLight.accent;
        priorityIcon = Icons.notifications;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingS,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority Indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Icon(
                      priorityIcon,
                      size: 20,
                      color: priorityColor,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),

                  // Title and Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isHighPriority) ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: priorityColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (author.isNotEmpty) ...[
                              Icon(
                                Icons.person_outline,
                                size: 12,
                                color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                author,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingM),
                            ],
                            if (createdAt != null) ...[
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                  ),
                ],
              ),

              // Message Preview
              if (message.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}

class _AnnouncementDetailSheet extends StatelessWidget {
  final Announcement announcement;
  final bool isDark;

  const _AnnouncementDetailSheet({
    required this.announcement,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final title = announcement.title;
    final message = announcement.message;
    final priority = announcement.priority.toLowerCase();
    final createdAt = announcement.createdAt;
    final author = announcement.createdBy?.toString() ?? '';

    Color priorityColor;
    String priorityLabel;

    switch (priority) {
      case 'high':
        priorityColor = isDark ? AppColors.error : AppColorsLight.error;
        priorityLabel = 'Important';
        break;
      case 'low':
        priorityColor = isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;
        priorityLabel = 'Low Priority';
        break;
      default:
        priorityColor = isDark ? AppColors.accent : AppColorsLight.accent;
        priorityLabel = 'Normal';
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      priorityLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: priorityColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingM),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingS),

                  // Meta Info
                  Row(
                    children: [
                      if (author.isNotEmpty) ...[
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          author,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingL),
                      ],
                      if (createdAt != null) ...[
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatFullDate(createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  Divider(
                    color: isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight,
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Message
                  Text(
                    message.isNotEmpty ? message : 'No additional details.',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
