import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/more_screen_app_bar.dart';
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
  String _selectedFilter = 'all'; // 'all', 'urgent', 'high', 'normal'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Get announcements for students using provider
    final announcementsAsync = ref.watch(announcementListProvider(targetAudience: 'students'));

    void _handleReload() {
      ref.invalidate(announcementListProvider(targetAudience: 'students'));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: MoreScreenAppBar(
        title: 'Announcements',
        onReload: _handleReload,
        isDark: isDark,
        onBack: widget.onBack,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _handleReload();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _FilterChip(
                    label: 'Urgent',
                    isSelected: _selectedFilter == 'urgent',
                    onTap: () => setState(() => _selectedFilter = 'urgent'),
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _FilterChip(
                    label: 'High',
                    isSelected: _selectedFilter == 'high',
                    onTap: () => setState(() => _selectedFilter = 'high'),
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _FilterChip(
                    label: 'Normal',
                    isSelected: _selectedFilter == 'normal',
                    onTap: () => setState(() => _selectedFilter = 'normal'),
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ),

          // Announcements List
          Expanded(
            child: announcementsAsync.when(
                loading: () => const ListSkeleton(itemCount: 5),
                error: (error, stack) => ErrorDisplay(
                  message: 'Failed to load announcements: ${error.toString()}',
                  onRetry: () => ref.invalidate(announcementListProvider(targetAudience: 'students')),
                ),
                data: (announcements) {
                  // Filter by priority
                  final filteredAnnouncements = _selectedFilter == 'all'
                      ? announcements
                      : announcements.where((a) => a.priority == _selectedFilter).toList();

                  if (filteredAnnouncements.isEmpty) {
                    return EmptyState.noAnnouncements();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      final announcement = filteredAnnouncements[index];
                      return _buildAnnouncementCard(announcement);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      onTap: () => _showAnnouncementDetails(context, announcement),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (announcement.priority == 'urgent' || announcement.priority == 'high')
                          const Icon(
                            Icons.priority_high,
                            size: 16,
                            color: AppColors.error,
                          ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      announcement.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: announcement.priorityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  announcement.priority.toUpperCase(),
                  style: TextStyle(
                    color: announcement.priorityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM, yyyy').format(announcement.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAnnouncementDetails(BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          announcement.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: announcement.priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      announcement.priority.toUpperCase(),
                      style: TextStyle(
                        color: announcement.priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Text(
                    DateFormat('dd MMM, yyyy').format(announcement.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                announcement.message,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              if (announcement.createdByName != null) ...[
                const SizedBox(height: AppDimensions.spacingM),
                const Divider(),
                const SizedBox(height: AppDimensions.spacingS),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Posted by ${announcement.createdByName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.accent;
    
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? chipColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
