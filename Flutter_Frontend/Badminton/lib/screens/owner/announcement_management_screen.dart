import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/more_screen_app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement.dart';
import 'package:intl/intl.dart';

/// Announcement Management Screen - Create and manage announcements
/// Matches React reference: AnnouncementManagement.tsx
class AnnouncementManagementScreen extends ConsumerStatefulWidget {
  const AnnouncementManagementScreen({super.key});

  @override
  ConsumerState<AnnouncementManagementScreen> createState() => _AnnouncementManagementScreenState();
}

class _AnnouncementManagementScreenState extends ConsumerState<AnnouncementManagementScreen> {
  bool _showAddForm = false;
  bool _isLoading = false;
  Announcement? _editingAnnouncement; // Track if we're editing
  String _selectedFilter = 'all'; // 'all', 'urgent', 'high', 'normal'

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedPriority = 'normal'; // 'normal', 'high', 'urgent'
  String _selectedTargetAudience = 'all'; // 'all', 'students', 'coaches'
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }


  void _editAnnouncement(Announcement announcement) {
    setState(() {
      _showAddForm = true;
      _editingAnnouncement = announcement;
      _titleController.text = announcement.title;
      _messageController.text = announcement.message;
      _selectedPriority = announcement.priority;
      _selectedTargetAudience = announcement.targetAudience;
      _scheduledAt = announcement.scheduledAt;
    });
  }

  Future<void> _saveAnnouncement() async {
    if (_titleController.text.trim().isEmpty) {
      SuccessSnackbar.showError(context, 'Please enter announcement title');
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      SuccessSnackbar.showError(context, 'Please enter announcement message');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authState = await ref.read(authProvider.future);
      
      int? createdBy;
      String? creatorType;
      if (authState is Authenticated) {
        createdBy = authState.userId;
        // Map userType to creator_type for backend
        // userType can be "owner", "coach", or "student"
        // creator_type should be "owner" or "coach"
        if (authState.userType == 'owner') {
          creatorType = 'owner';
        } else if (authState.userType == 'coach') {
          creatorType = 'coach';
        }
      }

      // Validate required fields
      if (createdBy == null || creatorType == null) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Unable to determine user information. Please try again.');
        }
        setState(() => _isLoading = false);
        return;
      }

      final announcementData = {
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'target_audience': _selectedTargetAudience,
        'priority': _selectedPriority,
        'created_by': createdBy,
        'creator_type': creatorType,
        'scheduled_at': _scheduledAt?.toIso8601String(),
      };

      final announcementManager = ref.read(announcementManagerProvider().notifier);
      
      if (_editingAnnouncement != null) {
        await announcementManager.updateAnnouncement(_editingAnnouncement!.id, announcementData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Announcement updated successfully');
        }
      } else {
        await announcementManager.createAnnouncement(announcementData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Announcement created successfully');
        }
      }

      if (mounted) {
        setState(() {
          _showAddForm = false;
          _titleController.clear();
          _messageController.clear();
          _selectedPriority = 'normal';
          _selectedTargetAudience = 'all';
          _scheduledAt = null;
          _editingAnnouncement = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to ${_editingAnnouncement != null ? 'update' : 'create'} announcement: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteAnnouncement(int id) async {
    final confirmed = await ConfirmationDialog.showDelete(
      context,
      'Announcement',
    );

    if (confirmed == true && mounted) {
      try {
        final announcementManager = ref.read(announcementManagerProvider().notifier);
        await announcementManager.deleteAnnouncement(id);
        if (mounted) {
          SuccessSnackbar.show(context, 'Announcement deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Failed to delete announcement: ${e.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_showAddForm) {
      return _buildAddForm();
    }

    void handleReload() {
      ref.invalidate(announcementManagerProvider);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: MoreScreenAppBar(
        title: 'Announcements',
        onReload: handleReload,
        isDark: isDark,
        additionalActions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? AppColors.accent : AppColorsLight.accent,
            ),
            onPressed: () => setState(() => _showAddForm = true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          handleReload();
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
              child: Consumer(
                builder: (context, ref, child) {
                  final announcementsAsync = ref.watch(announcementManagerProvider());
                  
                  return announcementsAsync.when(
                    loading: () => const ListSkeleton(itemCount: 5),
                    error: (error, stack) => ErrorDisplay(
                      message: 'Failed to load announcements: ${error.toString()}',
                      onRetry: () => ref.invalidate(announcementManagerProvider()),
                    ),
                    data: (announcements) {
                      // Filter by priority
                      final filteredAnnouncements = _selectedFilter == 'all'
                          ? announcements
                          : announcements.where((a) => a.priority == _selectedFilter).toList();

                      if (filteredAnnouncements.isEmpty) {
                        return EmptyState.noAnnouncements(
                          onCreate: () => setState(() => _showAddForm = true),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredAnnouncements.length,
                        itemBuilder: (context, index) {
                          final announcement = filteredAnnouncements[index];
                          return _buildAnnouncementCard(announcement);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddForm() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => setState(() => _showAddForm = false),
        ),
        title: const Text(
          'Create Announcement',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter announcement title',
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Message
              CustomTextField(
                controller: _messageController,
                label: 'Message',
                hint: 'Enter announcement message',
                maxLines: 4,
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Priority
              const Text(
                'Priority',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Row(
                children: [
                  Expanded(
                    child: _PriorityButton(
                      label: 'Low',
                      value: 'normal',
                      selected: _selectedPriority,
                      onTap: () => setState(() => _selectedPriority = 'normal'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: _PriorityButton(
                      label: 'Medium',
                      value: 'high',
                      selected: _selectedPriority,
                      onTap: () => setState(() => _selectedPriority = 'high'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: _PriorityButton(
                      label: 'High',
                      value: 'urgent',
                      selected: _selectedPriority,
                      onTap: () => setState(() => _selectedPriority = 'urgent'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Target Audience
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedTargetAudience,
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                  dropdownColor: AppColors.cardBackground,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'students', child: Text('Students Only')),
                    DropdownMenuItem(value: 'coaches', child: Text('Coaches Only')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedTargetAudience = value);
                    }
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Scheduled At (Optional)
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: InkWell(
                  onTap: () async {
                    if (!mounted) return;
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledAt ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null && mounted) {
                        setState(() {
                          _scheduledAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: Text(
                          _scheduledAt != null
                              ? DateFormat('dd MMM, yyyy • hh:mm a').format(_scheduledAt!)
                              : 'Schedule for later (Optional)',
                          style: TextStyle(
                            color: _scheduledAt != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_scheduledAt != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          color: AppColors.textSecondary,
                          onPressed: () => setState(() => _scheduledAt = null),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Publish Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _editingAnnouncement != null ? 'Update Announcement' : 'Publish Announcement',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
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
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                        color: AppColors.cardBackground,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: AppColors.textPrimary),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                              ],
                            ),
                            onTap: () {
                              Future.delayed(Duration.zero, () {
                                _editAnnouncement(announcement);
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                            onTap: () => _deleteAnnouncement(announcement.id),
                          ),
                        ],
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
              const SizedBox(width: AppDimensions.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  announcement.targetAudience.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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
}

class _PriorityButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _PriorityButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
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
