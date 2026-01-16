import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
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

  Future<List<Announcement>> _loadAnnouncements() async {
    try {
      final announcementService = ref.read(announcementServiceProvider);
      final announcements = await announcementService.getAnnouncements();
      return announcements;
    } catch (e) {
      return <Announcement>[];
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter announcement title')),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter announcement message')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final announcementService = ref.read(announcementServiceProvider);
      final authState = await ref.read(authProvider.future);
      
      int? createdBy;
      if (authState is Authenticated) {
        createdBy = authState.userId;
      }

      final announcementData = {
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'target_audience': _selectedTargetAudience,
        'priority': _selectedPriority,
        'created_by': createdBy,
        'scheduled_at': _scheduledAt?.toIso8601String(),
      };

      if (_editingAnnouncement != null) {
        await announcementService.updateAnnouncement(_editingAnnouncement!.id, announcementData);
      } else {
        await announcementService.createAnnouncement(announcementData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingAnnouncement != null
              ? 'Announcement updated successfully'
              : 'Announcement created successfully')),
        );
        setState(() {
          _showAddForm = false;
          _titleController.clear();
          _messageController.clear();
          _selectedPriority = 'normal';
          _selectedTargetAudience = 'all';
          _scheduledAt = null;
          _editingAnnouncement = null;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create announcement: $e')),
        );
      }
    }
  }

  Future<void> _deleteAnnouncement(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Announcement', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to delete this announcement?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final announcementService = ref.read(announcementServiceProvider);
        await announcementService.deleteAnnouncement(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement deleted successfully')),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete announcement: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      return _buildAddForm();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Announcements',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: () => setState(() => _showAddForm = true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<List<Announcement>>(
          future: _loadAnnouncements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingSpinner());
            }

            if (snapshot.hasError) {
              return ErrorDisplay(
                message: 'Failed to load announcements',
                onRetry: () => setState(() {}),
              );
            }

            final announcements = snapshot.data ?? [];

            if (announcements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    const Text(
                      'No announcements yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _showAddForm = true),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Announcement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(announcement);
              },
            );
          },
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
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledAt ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
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
                      ? const LoadingSpinner()
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
