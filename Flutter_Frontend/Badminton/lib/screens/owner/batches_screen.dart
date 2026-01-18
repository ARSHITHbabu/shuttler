import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
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
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();
  final _feesController = TextEditingController();
  DateTime? _startDate;
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
    _capacityController.dispose();
    _locationController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  Future<void> _loadCoaches() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(ApiEndpoints.coaches);
      if (response.data is List && mounted) {
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
      _startTime = null;
      _endTime = null;
      _capacityController.clear();
      _locationController.clear();
      _feesController.clear();
      _startDate = null;
      _selectedCoachIds.clear();
      _selectedDays.clear();
    });
  }

  void _openEditForm(Batch batch) {
    // Parse timing string (e.g., "6:00 AM - 7:30 AM") to TimeOfDay
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    
    if (batch.timing.contains(' - ')) {
      final parts = batch.timing.split(' - ');
      if (parts.length == 2) {
        final startTimeStr = parts[0].trim();
        final endTimeStr = parts[1].trim();
        
        // Parse start time
        startTime = _parseTimeString(startTimeStr);
        // Parse end time
        endTime = _parseTimeString(endTimeStr);
      }
    }
    
    // Parse start_date string to DateTime
    DateTime? startDate;
    try {
      startDate = DateTime.parse(batch.startDate);
    } catch (e) {
      // If parsing fails, use null
    }
    
    setState(() {
      _showAddForm = true;
      _editingBatch = batch;
      _nameController.text = batch.name;
      _startTime = startTime;
      _endTime = endTime;
      _capacityController.text = batch.capacity.toString();
      _locationController.text = batch.location ?? '';
      _feesController.text = batch.fees;
      _startDate = startDate;
      _selectedCoachIds.clear();
      if (batch.coachId != null) {
        _selectedCoachIds.add(batch.coachId!);
      }
      _selectedDays.clear();
      _selectedDays.addAll(batch.days);
    });
  }

  /// Helper method to parse time string to TimeOfDay
  /// Supports formats like "6:00 AM", "18:00", etc.
  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      // Try parsing formats like "6:00 AM", "18:00", etc.
      final timeFormat = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false);
      final match = timeFormat.firstMatch(timeStr);
      
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        final period = match.group(3)?.toUpperCase();
        
        // Convert to 24-hour format if AM/PM is present
        if (period != null) {
          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }
        }
        
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  /// Helper method to format TimeOfDay to string (e.g., "6:00 AM")
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate time fields
    if (_startTime == null) {
      SuccessSnackbar.showError(context, 'Please select start time');
      return;
    }
    if (_endTime == null) {
      SuccessSnackbar.showError(context, 'Please select end time');
      return;
    }
    
    if (_selectedDays.isEmpty) {
      SuccessSnackbar.showError(context, 'Please select at least one day');
      return;
    }

    try {
      // Format times as strings
      final startTimeStr = _formatTimeOfDay(_startTime!);
      final endTimeStr = _formatTimeOfDay(_endTime!);
      
      // Get coach assignment (only first coach if multiple selected, or null if none)
      int? assignedCoachId;
      String? assignedCoachName;
      if (_selectedCoachIds.isNotEmpty) {
        assignedCoachId = _selectedCoachIds.first;
        try {
          assignedCoachName = _coaches.firstWhere((c) => c.id == assignedCoachId).name;
        } catch (e) {
          // Coach not found in list, name will be null
        }
      }
      
      // Prepare batch data - only include changed fields when editing
      final batchData = <String, dynamic>{};
      
      if (_editingBatch != null) {
        // When editing, only send fields that have changed
        final originalBatch = _editingBatch!;
        final originalTiming = originalBatch.timing;
        final newTiming = '$startTimeStr - $endTimeStr';
        final originalPeriod = originalBatch.period;
        final newPeriod = _selectedDays.join(', ');
        final originalDays = originalBatch.days.join(', ');
        final newDays = _selectedDays.join(', ');
        
        // Check if name changed
        if (_nameController.text.trim() != originalBatch.name) {
          batchData['name'] = _nameController.text.trim();
          batchData['batch_name'] = _nameController.text.trim();
        }
        
        // Check if timing changed
        if (newTiming != originalTiming) {
          batchData['timing'] = newTiming;
          batchData['start_time'] = startTimeStr;
          batchData['end_time'] = endTimeStr;
        }
        
        // Check if period/days changed
        if (newPeriod != originalPeriod || newDays != originalDays) {
          batchData['period'] = newPeriod;
          batchData['days'] = newDays;
        }
        
        // Check if capacity changed
        final newCapacity = int.parse(_capacityController.text.trim());
        if (newCapacity != originalBatch.capacity) {
          batchData['capacity'] = newCapacity;
        }
        
        // Handle location - preserve existing if field is empty, only update if changed
        final locationValue = _locationController.text.trim();
        if (locationValue.isEmpty) {
          // Field is empty - preserve original location (don't send it)
          // Only send if we want to explicitly clear it (user cleared a previously set location)
          if (originalBatch.location != null && originalBatch.location!.isNotEmpty) {
            // User cleared a location that existed - preserve it by not sending location field
            // If you want to allow clearing, uncomment the next line:
            // batchData['location'] = null;
          }
        } else {
          // Field has value - check if it changed
          if (locationValue != originalBatch.location) {
            batchData['location'] = locationValue;
          }
        }
        
        // Handle fees - preserve existing if not changed
        final feesValue = _feesController.text.trim();
        if (feesValue.isEmpty) {
          // Field is empty - preserve original fees (don't send it)
        } else if (feesValue != originalBatch.fees) {
          // Fees changed - send new value
          batchData['fees'] = feesValue;
        }
        // If feesValue == originalBatch.fees, don't send it (no change)
        
        // Handle start_date - preserve existing if not changed
        if (_startDate != null) {
          final newStartDate = _startDate!.toIso8601String().split('T')[0];
          if (newStartDate != originalBatch.startDate) {
            batchData['start_date'] = newStartDate;
          }
        }
        // If _startDate is null, preserve original (don't send it)
        
        // Handle coach assignment - only send if changed
        final originalCoachId = originalBatch.coachId;
        if (assignedCoachId != originalCoachId) {
          // Coach assignment changed
          if (assignedCoachId != null) {
            batchData['assigned_coach_id'] = assignedCoachId;
            if (assignedCoachName != null) {
              batchData['assigned_coach_name'] = assignedCoachName;
            }
          } else {
            // Coach was removed
            batchData['assigned_coach_id'] = null;
            batchData['assigned_coach_name'] = null;
          }
        }
        // If coach didn't change, don't send coach fields
      } else {
        // When creating, send all required fields
        batchData['name'] = _nameController.text.trim();
        batchData['batch_name'] = _nameController.text.trim();
        batchData['timing'] = '$startTimeStr - $endTimeStr';
        batchData['period'] = _selectedDays.join(', ');
        batchData['days'] = _selectedDays.join(', ');
        batchData['start_time'] = startTimeStr;
        batchData['end_time'] = endTimeStr;
        batchData['capacity'] = int.parse(_capacityController.text.trim());
        batchData['location'] = _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim();
        batchData['fees'] = _feesController.text.trim().isEmpty 
            ? '0' 
            : _feesController.text.trim();
        batchData['start_date'] = _startDate != null
            ? _startDate!.toIso8601String().split('T')[0]
            : DateTime.now().toIso8601String().split('T')[0];
        batchData['created_by'] = 'owner'; // TODO: Get from auth
        
        // Add coach assignment (singular, not plural)
        if (assignedCoachId != null) {
          batchData['assigned_coach_id'] = assignedCoachId;
          if (assignedCoachName != null) {
            batchData['assigned_coach_name'] = assignedCoachName;
          }
        } else {
          // No coach assigned
          batchData['assigned_coach_id'] = null;
          batchData['assigned_coach_name'] = null;
        }
      }

      if (_editingBatch != null) {
        await ref.read(batchListProvider.notifier).updateBatch(
              _editingBatch!.id,
              batchData,
            );
        if (mounted) {
          SuccessSnackbar.show(context, 'Batch updated successfully');
        }
      } else {
        await ref.read(batchListProvider.notifier).createBatch(batchData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Batch created successfully');
        }
      }

      if (mounted) {
        setState(() {
          _showAddForm = false;
          _editingBatch = null;
        });
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteBatch(Batch batch) async {
    final widgetRef = ref;
    final isMounted = mounted;
    
    ConfirmationDialog.showDelete(
      context,
      batch.name,
      onConfirm: () async {
        try {
          await widgetRef.read(batchListProvider.notifier).deleteBatch(batch.id);
          if (isMounted && mounted) {
            SuccessSnackbar.show(context, 'Batch deleted successfully');
          }
        } catch (e) {
          if (isMounted && mounted) {
            SuccessSnackbar.showError(context, 'Error: ${e.toString()}');
          }
        }
      },
    );
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
                            child: NeumorphicContainer(
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
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          Expanded(
                            child: NeumorphicContainer(
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
                        controller: _feesController,
                        label: 'Fees',
                        hint: 'e.g., 5000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _editingBatch != null ? null : 'Required';
                          }
                          // Allow numeric values
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      NeumorphicContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
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
                                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                    : 'Select start date',
                                style: TextStyle(
                                  color: _startDate != null
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
                        'Assign Coach (Optional)',
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
                                  // Only allow one coach selection
                                  _selectedCoachIds.clear();
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
                        Builder(
                          builder: (context) {
                            try {
                              final coachName = _coaches.firstWhere((c) => c.id == _selectedCoachIds.first).name;
                              return Text(
                                'Selected: $coachName',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            } catch (e) {
                              return Text(
                                'Selected: Coach ${_selectedCoachIds.first}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            }
                          },
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
              child: ListSkeleton(itemCount: 5),
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
          // Days - always shown
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                label: batch.daysString,
              ),
            ],
          ),
          // Coach Name - conditionally shown (check both ID and name)
          if (batch.assignedCoachId != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.person_outline,
                  label: batch.coachName ?? 'Coach ${batch.assignedCoachId}',
                ),
              ],
            ),
          ],
          // Location - conditionally shown
          if (batch.location != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: batch.location!,
                ),
              ],
            ),
          ],
          // Capacity - always shown
          const SizedBox(height: AppDimensions.spacingS),
          Row(
            children: [
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
