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
import '../../models/schedule.dart';
import '../../models/batch.dart';
import '../../models/coach.dart';
import 'package:intl/intl.dart';

/// Session Management Screen - Manage practice/tournament/camp sessions
/// Matches React reference: SessionManagement.tsx (adapted for Schedule model)
class SessionManagementScreen extends ConsumerStatefulWidget {
  const SessionManagementScreen({super.key});

  @override
  ConsumerState<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends ConsumerState<SessionManagementScreen> {
  bool _showAddForm = false;
  Schedule? _selectedSession;
  String _selectedTab = 'upcoming'; // 'upcoming' or 'past'
  bool _isLoading = false;
  Schedule? _editingSession; // Track if we're editing an existing session

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedSessionType = 'practice';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _selectedBatchId;
  int? _selectedCoachId;
  List<Batch> _batches = [];
  List<Coach> _coaches = [];

  @override
  void initState() {
    super.initState();
    _loadBatchesAndCoaches();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadBatchesAndCoaches() async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final coachService = ref.read(coachServiceProvider);
      final batches = await batchService.getBatches();
      final coaches = await coachService.getCoaches();
      setState(() {
        _batches = batches;
        _coaches = coaches;
      });
    } catch (e) {
      // Silently fail
    }
  }

  Future<List<Schedule>> _loadSessions() async {
    try {
      final scheduleService = ref.read(scheduleServiceProvider);
      List<Schedule> allSessions = [];
      
      // Since backend doesn't have GET /schedules/, we need to fetch schedules for each batch
      // or use date-based fetching. Let's fetch for all batches we have loaded.
      if (_batches.isNotEmpty) {
        for (final batch in _batches) {
          try {
            final batchSessions = await scheduleService.getSchedules(batchId: batch.id);
            allSessions.addAll(batchSessions);
          } catch (e) {
            // Silently fail for individual batch
            continue;
          }
        }
      }
      
      // Also try to get today's schedules as a fallback
      try {
        final todaySessions = await scheduleService.getSchedules(startDate: DateTime.now());
        // Merge with existing, avoiding duplicates
        for (var session in todaySessions) {
          if (!allSessions.any((s) => s.id == session.id)) {
            allSessions.add(session);
          }
        }
      } catch (e) {
        // Silently fail for date-based fetch
      }
      
      return allSessions;
    } catch (e) {
      return [];
    }
  }

  void _editSession(Schedule session) {
    setState(() {
      _selectedSession = null;
      _showAddForm = true;
      _editingSession = session;
      _titleController.text = session.title;
      _descriptionController.text = session.description ?? '';
      _locationController.text = session.location ?? '';
      _selectedSessionType = session.sessionType;
      _selectedDate = session.date;
      _selectedBatchId = session.batchId;
      _selectedCoachId = session.coachId;
      
      // Parse time strings
      if (session.startTime != null) {
        final parts = session.startTime!.split(':');
        if (parts.length == 2) {
          _startTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
      if (session.endTime != null) {
        final parts = session.endTime!.split(':');
        if (parts.length == 2) {
          _endTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    });
  }

  Future<void> _saveSession() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter session title')),
      );
      return;
    }

    // Make batch_id required (backend requires it)
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a batch')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final scheduleService = ref.read(scheduleServiceProvider);
      final authState = await ref.read(authProvider.future);
      
      // Get created_by from auth (convert to string as backend expects string)
      String? createdBy;
      if (authState is Authenticated) {
        createdBy = authState.userId.toString();
      }

      // Map Flutter format to backend format
      // Backend expects: batch_id (int, required), date (str), activity (str, required), 
      // created_by (str, required), description (str, optional)
      final sessionData = {
        'batch_id': _selectedBatchId!, // Required, not nullable
        'date': _selectedDate.toIso8601String().split('T')[0],
        'activity': _titleController.text.trim(), // Map title to activity field
        'created_by': createdBy ?? 'owner', // Required
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      };

      if (_editingSession != null) {
        await scheduleService.updateSchedule(_editingSession!.id, sessionData);
      } else {
        await scheduleService.createSchedule(sessionData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingSession != null
              ? 'Session updated successfully'
              : 'Session created successfully')),
        );
        setState(() {
          _showAddForm = false;
          _titleController.clear();
          _descriptionController.clear();
          _locationController.clear();
          _selectedSessionType = 'practice';
          _selectedDate = DateTime.now();
          _startTime = null;
          _endTime = null;
          _selectedBatchId = null;
          _selectedCoachId = null;
          _editingSession = null;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${_editingSession != null ? 'update' : 'create'} session: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSession != null) {
      return _buildSessionDetail();
    }

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
          'Sessions',
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
      body: Column(
        children: [
          // Tab Selector
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Upcoming',
                      isActive: _selectedTab == 'upcoming',
                      onTap: () => setState(() => _selectedTab = 'upcoming'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      label: 'Past',
                      isActive: _selectedTab == 'past',
                      onTap: () => setState(() => _selectedTab = 'past'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sessions List
          Expanded(
            child: FutureBuilder<List<Schedule>>(
              future: _loadSessions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                  return const Center(child: LoadingSpinner());
                }

                if (snapshot.hasError) {
                  return ErrorDisplay(
                    message: 'Failed to load sessions',
                    onRetry: () => setState(() {}),
                  );
                }

                final allSessions = snapshot.data ?? [];
                final now = DateTime.now();
                final sessions = _selectedTab == 'upcoming'
                    ? allSessions.where((s) => !s.isPast).toList()
                    : allSessions.where((s) => s.isPast).toList();

                if (sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        Text(
                          _selectedTab == 'upcoming'
                              ? 'No upcoming sessions'
                              : 'No past sessions',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return _buildSessionCard(session);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Schedule session) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      onTap: () => setState(() => _selectedSession = session),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd MMM, yyyy').format(session.date)}${session.startTime != null && session.endTime != null ? ' • ${session.startTime} - ${session.endTime}' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: _getSessionTypeColor(session.sessionType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  session.sessionType.toUpperCase(),
                  style: TextStyle(
                    color: _getSessionTypeColor(session.sessionType),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (session.location != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  session.location!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (session.coachName != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  session.coachName!,
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
        title: Text(
          _editingSession != null ? 'Edit Session' : 'Create Session',
          style: const TextStyle(
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
              // Session Type
              const Text(
                'Session Type',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Row(
                children: [
                  Expanded(
                    child: _SessionTypeButton(
                      label: 'Practice',
                      value: 'practice',
                      selected: _selectedSessionType,
                      onTap: () => setState(() => _selectedSessionType = 'practice'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: _SessionTypeButton(
                      label: 'Tournament',
                      value: 'tournament',
                      selected: _selectedSessionType,
                      onTap: () => setState(() => _selectedSessionType = 'tournament'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: _SessionTypeButton(
                      label: 'Camp',
                      value: 'camp',
                      selected: _selectedSessionType,
                      onTap: () => setState(() => _selectedSessionType = 'camp'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter session title',
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Date
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        DateFormat('dd MMM, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Start Time
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => _startTime = time);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        _startTime != null
                            ? _startTime!.format(context)
                            : 'Select start time',
                        style: TextStyle(
                          color: _startTime != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // End Time
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => _endTime = time);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        _endTime != null
                            ? _endTime!.format(context)
                            : 'Select end time',
                        style: TextStyle(
                          color: _endTime != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Batch Selector (Required)
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: DropdownButtonFormField<int>(
                  value: _selectedBatchId,
                  decoration: const InputDecoration(
                    labelText: 'Batch *',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                  dropdownColor: AppColors.cardBackground,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: _batches.map((batch) {
                    return DropdownMenuItem<int>(
                      value: batch.id,
                      child: Text(batch.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedBatchId = value),
                  validator: (value) => value == null ? 'Batch is required' : null,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Coach Selector
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: DropdownButtonFormField<int>(
                  value: _selectedCoachId,
                  decoration: const InputDecoration(
                    labelText: 'Coach (Optional)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                  dropdownColor: AppColors.cardBackground,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('None'),
                    ),
                    ..._coaches.map((coach) {
                      return DropdownMenuItem<int>(
                        value: coach.id,
                        child: Text(coach.name),
                      );
                    }),
                  ],
                  onChanged: (value) => setState(() => _selectedCoachId = value),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Location
              CustomTextField(
                controller: _locationController,
                label: 'Location (Optional)',
                hint: 'Enter location',
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Enter description',
                maxLines: 3,
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
                  ),
                  child: _isLoading
                      ? const LoadingSpinner()
                      : Text(
                          _editingSession != null ? 'Update Session' : 'Create Session',
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

  Widget _buildSessionDetail() {
    final session = _selectedSession!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => setState(() => _selectedSession = null),
        ),
        title: Text(
          session.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            color: AppColors.cardBackground,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    _editSession(session);
                  });
                },
              ),
              PopupMenuItem(
                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.cardBackground,
                      title: const Text('Delete Session', style: TextStyle(color: AppColors.textPrimary)),
                      content: const Text('Are you sure you want to delete this session?', style: TextStyle(color: AppColors.textSecondary)),
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
                      final scheduleService = ref.read(scheduleServiceProvider);
                      await scheduleService.deleteSchedule(session.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session deleted successfully')),
                        );
                        setState(() => _selectedSession = null);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete session: $e')),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Type', session.sessionType.toUpperCase()),
                    _buildDetailRow('Date', DateFormat('dd MMM, yyyy').format(session.date)),
                    if (session.startTime != null && session.endTime != null)
                      _buildDetailRow('Time', '${session.startTime} - ${session.endTime}'),
                    if (session.duration != null)
                      _buildDetailRow('Duration', '${session.duration} minutes'),
                    if (session.location != null)
                      _buildDetailRow('Location', session.location!),
                    if (session.coachName != null)
                      _buildDetailRow('Coach', session.coachName!),
                    if (session.batchName != null)
                      _buildDetailRow('Batch', session.batchName!),
                    if (session.description != null) ...[
                      const SizedBox(height: AppDimensions.spacingM),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSessionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'practice':
        return AppColors.accent;
      case 'tournament':
        return Colors.blue;
      case 'camp':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionTypeButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _SessionTypeButton({
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
