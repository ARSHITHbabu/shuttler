import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/session_provider.dart';
import '../../providers/batch_provider.dart';
import '../../models/session.dart';
import '../../models/batch.dart';

/// Season Management Screen - Manage seasons that group batches
/// Separate from SessionManagementScreen which manages practice/tournament/camp sessions
class SessionSeasonManagementScreen extends ConsumerStatefulWidget {
  const SessionSeasonManagementScreen({super.key});

  @override
  ConsumerState<SessionSeasonManagementScreen> createState() => _SessionSeasonManagementScreenState();
}

class _SessionSeasonManagementScreenState extends ConsumerState<SessionSeasonManagementScreen> {
  bool _showAddForm = false;
  bool _isLoading = false;
  Session? _editingSession;
  String _selectedTab = 'active'; // 'active' or 'archived'

  final _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = 'active';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openAddForm() {
    setState(() {
      _showAddForm = true;
      _editingSession = null;
      _nameController.clear();
      _startDate = null;
      _endDate = null;
      _selectedStatus = 'active';
    });
  }

  void _openEditForm(Session session) {
    setState(() {
      _showAddForm = true;
      _editingSession = session;
      _nameController.text = session.name;
      _startDate = session.startDate;
      _endDate = session.endDate;
      _selectedStatus = session.status;
    });
  }

  Future<void> _saveSession() async {
    if (_nameController.text.trim().isEmpty) {
      SuccessSnackbar.showError(context, 'Please enter season name');
      return;
    }

    if (_startDate == null) {
      SuccessSnackbar.showError(context, 'Please select start date');
      return;
    }

    if (_endDate == null) {
      SuccessSnackbar.showError(context, 'Please select end date');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      SuccessSnackbar.showError(context, 'End date must be after start date');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final sessionData = {
        'name': _nameController.text.trim(),
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate!.toIso8601String().split('T')[0],
        'status': _selectedStatus,
      };

      final statusFilter = _selectedTab == 'active' ? 'active' : 'archived';
      final sessionManager = ref.read(sessionManagerProvider(status: statusFilter).notifier);

      if (_editingSession != null) {
        await sessionManager.updateSession(_editingSession!.id, sessionData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Season updated successfully');
        }
      } else {
        await sessionManager.createSession(sessionData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Season created successfully');
        }
      }

      if (mounted) {
        setState(() {
          _showAddForm = false;
          _nameController.clear();
          _startDate = null;
          _endDate = null;
          _selectedStatus = 'active';
          _editingSession = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to ${_editingSession != null ? 'update' : 'create'} session: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteSession(int id) async {
    final confirmed = await ConfirmationDialog.showDelete(
      context,
      'Season',
    );

    if (confirmed == true && mounted) {
      try {
        final sessionManager = ref.read(sessionManagerProvider(status: _selectedTab).notifier);
        await sessionManager.deleteSession(id);
        if (mounted) {
          SuccessSnackbar.show(context, 'Session deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Failed to delete season: ${e.toString()}');
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
          'Season Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: _openAddForm,
          ),
        ],
      ),
      body: _buildSessionList(),
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
          onPressed: () {
            setState(() {
              _showAddForm = false;
              _editingSession = null;
              _nameController.clear();
              _startDate = null;
              _endDate = null;
              _selectedStatus = 'active';
            });
          },
        ),
        title: Text(
          _editingSession != null ? 'Edit Season' : 'Create Season',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Season Name',
              hint: 'e.g., Fall 2026, Winter 2026',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter season name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingM),
            
            // Start Date
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                    const SizedBox(width: AppDimensions.spacingM),
                    Text(
                      _startDate != null
                          ? DateFormat('dd MMM, yyyy').format(_startDate!)
                          : 'Select Start Date *',
                      style: TextStyle(
                        color: _startDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            
            // End Date
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 90)),
                    firstDate: _startDate ?? DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() => _endDate = date);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                    const SizedBox(width: AppDimensions.spacingM),
                    Text(
                      _endDate != null
                          ? DateFormat('dd MMM, yyyy').format(_endDate!)
                          : 'Select End Date *',
                      style: TextStyle(
                        color: _endDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            
            // Status
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Wrap(
              spacing: AppDimensions.spacingS,
              runSpacing: AppDimensions.spacingS,
              children: [
                _StatusChip(
                  label: 'Active',
                  value: 'active',
                  selected: _selectedStatus,
                  onTap: () => setState(() => _selectedStatus = 'active'),
                ),
                _StatusChip(
                  label: 'Archived',
                  value: 'archived',
                  selected: _selectedStatus,
                  onTap: () => setState(() => _selectedStatus = 'archived'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            
            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _editingSession != null ? 'Update Season' : 'Create Season',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    final statusFilter = _selectedTab == 'active' ? 'active' : 'archived';
    final sessionsAsync = ref.watch(sessionListProvider(status: statusFilter));

    return Column(
      children: [
        // Tabs
        Container(
          margin: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Active',
                  isSelected: _selectedTab == 'active',
                  onTap: () => setState(() => _selectedTab = 'active'),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Archived',
                  isSelected: _selectedTab == 'archived',
                  onTap: () => setState(() => _selectedTab = 'archived'),
                ),
              ),
            ],
          ),
        ),
        
        // Session List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final statusFilter = _selectedTab == 'active' ? 'active' : 'archived';
              ref.invalidate(sessionListProvider(status: statusFilter));
              ref.invalidate(sessionManagerProvider(status: statusFilter));
            },
            child: sessionsAsync.when(
              loading: () => const Center(child: ListSkeleton(itemCount: 5)),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load sessions: ${error.toString()}',
                onRetry: () {
                  final statusFilter = _selectedTab == 'active' ? 'active' : 'archived';
                  ref.invalidate(sessionListProvider(status: statusFilter));
                },
              ),
              data: (sessions) {
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
                            'No $_selectedTab seasons',
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
                      child: _SeasonCard(
                        session: session,
                        onEdit: () => _openEditForm(session),
                        onDelete: () => _deleteSession(session.id),
                        onViewBatches: () => _viewSeasonBatches(session),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _viewSeasonBatches(Session session) async {
    // Navigate to batches screen filtered by session
    // For now, show a dialog with batch count
    try {
      final batches = await ref.read(batchListProvider.future);
      final seasonBatches = batches.where((b) => b.sessionId == session.id).toList();
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            'Batches in ${session.name}',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: Container(
            width: double.maxFinite,
            child: seasonBatches.isEmpty
                ? const Text(
                    'No batches assigned to this season.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${seasonBatches.length} batch${seasonBatches.length == 1 ? '' : 'es'} assigned:',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...seasonBatches.map((b) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 8, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b.batchName,
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to load batches: ${e.toString()}');
      }
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _StatusChip({
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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final Session session;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewBatches;

  const _SeasonCard({
    required this.session,
    required this.onEdit,
    required this.onDelete,
    required this.onViewBatches,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd MMM, yyyy').format(session.startDate)} - ${DateFormat('dd MMM, yyyy').format(session.endDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: session.isActive ? AppColors.success : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  session.status.toUpperCase(),
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
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingS,
            children: [
              TextButton.icon(
                onPressed: onViewBatches,
                icon: const Icon(Icons.list, size: 16, color: AppColors.textSecondary),
                label: const Text(
                  'View Batches',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16, color: AppColors.accent),
                label: const Text(
                  'Edit',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, size: 16, color: AppColors.error),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
