import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/batch_provider.dart';
import '../../providers/service_providers.dart';
import '../../models/batch.dart';
import '../../models/coach.dart';
import '../../core/constants/api_endpoints.dart';

/// Batches Screen - List and manage batches
/// Matches React reference: BatchesScreen.tsx
class BatchesScreen extends ConsumerStatefulWidget {
  const BatchesScreen({super.key});

  @override
  ConsumerState<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends ConsumerState<BatchesScreen> {
  bool _showAddForm = false;
  Batch? _editingBatch;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();
  final List<int> _selectedCoachIds = [];
  final List<String> _selectedDays = [];
  List<Coach> _coaches = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCoaches() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(ApiEndpoints.coaches);
      if (response.data is List) {
        setState(() {
          _coaches = (response.data as List)
              .map((json) => Coach.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      // Silently fail - coaches will be empty
    }
  }

  void _openAddForm() {
    setState(() {
      _showAddForm = true;
      _editingBatch = null;
      _nameController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
      _capacityController.clear();
      _locationController.clear();
      _selectedCoachIds.clear();
      _selectedDays.clear();
    });
  }

  void _openEditForm(Batch batch) {
    // Parse timing string (e.g., "6:00 AM - 7:30 AM") to extract start and end times
    String startTime = '';
    String endTime = '';
    if (batch.timing.contains(' - ')) {
      final parts = batch.timing.split(' - ');
      if (parts.length == 2) {
        startTime = parts[0].trim();
        endTime = parts[1].trim();
      }
    }
    
    setState(() {
      _showAddForm = true;
      _editingBatch = batch;
      _nameController.text = batch.name;
      _startTimeController.text = startTime;
      _endTimeController.text = endTime;
      _capacityController.text = batch.capacity.toString();
      _locationController.text = batch.location ?? '';
      _selectedCoachIds.clear();
      if (batch.coachId != null) {
        _selectedCoachIds.add(batch.coachId!);
      }
      _selectedDays.clear();
      _selectedDays.addAll(batch.days);
    });
  }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    try {
      final batchData = {
        'name': _nameController.text.trim(),
        'batch_name': _nameController.text.trim(),
        'timing': '${_startTimeController.text.trim()} - ${_endTimeController.text.trim()}',
        'period': _selectedDays.join(', '),
        'days': _selectedDays.join(', '),
        'start_time': _startTimeController.text.trim(),
        'end_time': _endTimeController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'fees': '0', // Default fees
        'start_date': DateTime.now().toIso8601String().split('T')[0],
        'assigned_coach_ids': _selectedCoachIds,
        'assigned_coach_names': _selectedCoachIds.map((id) {
          return _coaches.firstWhere((c) => c.id == id).name;
        }).join(', '),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'created_by': 'owner', // TODO: Get from auth
      };

      if (_editingBatch != null) {
        await ref.read(batchListProvider.notifier).updateBatch(
              _editingBatch!.id,
              batchData,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        await ref.read(batchListProvider.notifier).createBatch(batchData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      setState(() {
        _showAddForm = false;
        _editingBatch = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteBatch(Batch batch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Batch',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${batch.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(batchListProvider.notifier).deleteBatch(batch.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(batchListProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(batchListProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Batches',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: _showAddForm ? null : _openAddForm,
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: NeumorphicInsetContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search batches...',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Add/Edit Batch Form (if shown)
          if (_showAddForm) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingBatch != null ? 'Edit Batch' : 'Add New Batch',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Batch Name',
                        hint: 'e.g., Morning Batch A',
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _startTimeController,
                              label: 'Start Time',
                              hint: 'e.g., 6:00 AM',
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          Expanded(
                            child: CustomTextField(
                              controller: _endTimeController,
                              label: 'End Time',
                              hint: 'e.g., 7:30 AM',
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      CustomTextField(
                        controller: _capacityController,
                        label: 'Capacity',
                        hint: 'e.g., 20',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final capacity = int.tryParse(value);
                          if (capacity == null || capacity <= 0) {
                            return 'Invalid capacity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      CustomTextField(
                        controller: _locationController,
                        label: 'Location (Optional)',
                        hint: 'e.g., Court 1',
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      const Text(
                        'Select Days',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Wrap(
                        spacing: AppDimensions.spacingS,
                        runSpacing: AppDimensions.spacingS,
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                            .map((day) => FilterChip(
                                  label: Text(day),
                                  selected: _selectedDays.contains(day),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedDays.add(day);
                                      } else {
                                        _selectedDays.remove(day);
                                      }
                                    });
                                  },
                                  selectedColor: AppColors.accent,
                                  labelStyle: TextStyle(
                                    color: _selectedDays.contains(day)
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      const Text(
                        'Assign Coaches (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Wrap(
                        spacing: AppDimensions.spacingS,
                        runSpacing: AppDimensions.spacingS,
                        children: _coaches.map((coach) {
                          final isSelected = _selectedCoachIds.contains(coach.id);
                          return FilterChip(
                            label: Text(coach.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCoachIds.add(coach.id);
                                } else {
                                  _selectedCoachIds.remove(coach.id);
                                }
                              });
                            },
                            selectedColor: AppColors.accent.withOpacity(0.3),
                            checkmarkColor: AppColors.accent,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                      if (_selectedCoachIds.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingS),
                        Text(
                          'Selected: ${_selectedCoachIds.length} coach(es)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.spacingL),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showAddForm = false;
                                  _editingBatch = null;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cardBackground,
                                foregroundColor: AppColors.textPrimary,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveBatch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // Batches List
          batchesAsync.when(
            data: (batches) {
              final filteredBatches = batches.where((batch) {
                if (_searchQuery.isEmpty) return true;
                return batch.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredBatches.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No batches yet'
                              : 'No batches found',
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

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: Column(
                  children: filteredBatches
                      .map((batch) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.spacingM,
                            ),
                            child: _BatchCard(
                              batch: batch,
                              onEdit: () => _openEditForm(batch),
                              onDelete: () => _deleteBatch(batch),
                              onViewStudents: () async {
                                final students = await ref.read(
                                  batchStudentsProvider(batch.id).future,
                                );
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.cardBackground,
                                      title: Text(
                                        'Students in ${batch.name}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: students.isEmpty
                                            ? const Text(
                                                'No students enrolled',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary,
                                                ),
                                              )
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: students.length,
                                                itemBuilder: (context, index) {
                                                  final student = students[index];
                                                  return ListTile(
                                                    title: Text(
                                                      student.name,
                                                      style: const TextStyle(
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      student.email,
                                                      style: const TextStyle(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ))
                      .toList(),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: Center(child: LoadingSpinner()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: ErrorDisplay(
                message: 'Failed to load batches',
                onRetry: () => ref.read(batchListProvider.notifier).refresh(),
              ),
            ),
          ),

          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewStudents;

  const _BatchCard({
    required this.batch,
    required this.onEdit,
    required this.onDelete,
    required this.onViewStudents,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                      batch.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          batch.timeRange,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                color: AppColors.cardBackground,
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  } else if (value == 'students') {
                    onViewStudents();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      'Edit',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'students',
                    child: Text(
                      'View Students',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                label: batch.daysString,
              ),
              if (batch.coachName != null) ...[
                const SizedBox(width: AppDimensions.spacingS),
                _InfoChip(
                  icon: Icons.person_outline,
                  label: batch.coachName!,
                ),
              ],
            ],
          ),
          if (batch.location != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: batch.location!,
                ),
                const Spacer(),
                Text(
                  'Capacity: ${batch.capacity}',
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
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        boxShadow: NeumorphicStyles.getSmallInsetShadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
