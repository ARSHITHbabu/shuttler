import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/batch_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/batch/batch_students_sheet.dart';
import '../../models/batch.dart';
import '../../models/coach.dart';
import '../../core/constants/api_endpoints.dart';

/// Batch Details Dialog - Comprehensive dialog for viewing and editing batch details
class BatchDetailsDialog extends ConsumerStatefulWidget {
  final Batch? batch;
  final bool isOwner;

  const BatchDetailsDialog({
    super.key,
    this.batch,
    required this.isOwner,
  });

  /// Show the dialog
  static Future<void> show(BuildContext context, {Batch? batch, required bool isOwner}) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BatchDetailsDialog(batch: batch, isOwner: isOwner),
    );
  }

  @override
  ConsumerState<BatchDetailsDialog> createState() => _BatchDetailsDialogState();
}

class _BatchDetailsDialogState extends ConsumerState<BatchDetailsDialog> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _locationController;
  late TextEditingController _feesController;
  
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _startDate;
  final List<int> _selectedCoachIds = [];
  final List<String> _selectedDays = [];
  int? _selectedSessionId;
  
  List<Coach> _coaches = [];
  bool _isLoadingCoaches = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.batch == null;
    
    _nameController = TextEditingController(text: widget.batch?.batchName ?? '');
    _capacityController = TextEditingController(text: widget.batch?.capacity.toString() ?? '');
    _locationController = TextEditingController(text: widget.batch?.location ?? '');
    _feesController = TextEditingController(text: widget.batch?.fees ?? '');
    
    if (widget.batch != null) {
      _parseBatchTimings();
      _selectedCoachIds.addAll(widget.batch!.assignedCoachIds);
      _selectedDays.addAll(widget.batch!.days);
      _selectedSessionId = widget.batch!.sessionId;
      try {
        _startDate = DateTime.parse(widget.batch!.startDate);
      } catch (e) {
        _startDate = DateTime.now();
      }
    } else {
      _startDate = DateTime.now();
    }
    
    _loadCoaches();
  }

  void _parseBatchTimings() {
    if (widget.batch == null) return;
    
    final timing = widget.batch!.timing;
    if (timing.contains(' - ')) {
      final parts = timing.split(' - ');
      if (parts.length == 2) {
        _startTime = _parseTimeString(parts[0].trim());
        _endTime = _parseTimeString(parts[1].trim());
      }
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final timeFormat = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false);
      final match = timeFormat.firstMatch(timeStr);
      
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        final period = match.group(3)?.toUpperCase();
        
        if (period != null) {
          if (period == 'PM' && hour != 12) hour += 12;
          else if (period == 'AM' && hour == 12) hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {}
    return null;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _loadCoaches() async {
    setState(() => _isLoadingCoaches = true);
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
      // Silently fail
    } finally {
      if (mounted) setState(() => _isLoadingCoaches = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startTime == null || _endTime == null) {
      SuccessSnackbar.showError(context, 'Please select timing');
      return;
    }
    
    if (_selectedDays.isEmpty) {
      SuccessSnackbar.showError(context, 'Please select at least one day');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final startTimeStr = _formatTimeOfDay(_startTime!);
      final endTimeStr = _formatTimeOfDay(_endTime!);
      final timing = '$startTimeStr - $endTimeStr';
      final days = _selectedDays.join(', ');

      final batchData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'batch_name': _nameController.text.trim(),
        'timing': timing,
        'period': days,
        'days': days,
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'capacity': int.parse(_capacityController.text.trim()),
        'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        'fees': _feesController.text.trim().isEmpty ? '0' : _feesController.text.trim(),
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'assigned_coach_ids': _selectedCoachIds,
        'session_id': _selectedSessionId,
      };

      if (widget.batch != null) {
        await ref.read(batchListProvider.notifier).updateBatch(widget.batch!.id, batchData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Batch updated successfully');
          Navigator.of(context).pop();
        }
      } else {
        batchData['created_by'] = 'owner'; // Initial fallback
        await ref.read(batchListProvider.notifier).createBatch(batchData);
        if (mounted) {
          SuccessSnackbar.show(context, 'Batch created successfully');
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) SuccessSnackbar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingL,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: screenWidth > 800 ? 600 : screenWidth * 0.95,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: _isEditing ? _buildEditForm() : _buildViewDetails(),
              ),
            ),
            if (_isEditing) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.batch == null ? 'Add New Batch' : (_isEditing ? 'Edit Batch' : 'Batch Details'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (widget.batch != null && widget.isOwner && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.accent),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Batch',
            ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetails() {
    final batch = widget.batch!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailItem(label: 'Batch Name', value: batch.batchName, icon: Icons.badge),
        _DetailItem(label: 'Timing', value: batch.timing, icon: Icons.access_time),
        _DetailItem(label: 'Days', value: batch.period, icon: Icons.calendar_today),
        _DetailItem(label: 'Capacity', value: '${batch.capacity} Students', icon: Icons.people),
        _DetailItem(label: 'Fees', value: batch.fees, icon: Icons.payments),
        _DetailItem(label: 'Location', value: batch.location ?? 'Not specified', icon: Icons.location_on),
        _DetailItem(label: 'Start Date', value: batch.startDate, icon: Icons.event),
        
        const SizedBox(height: AppDimensions.spacingL),
        const Text(
          'Assigned Coaches',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        if (batch.assignedCoaches.isEmpty)
          const Text('No coaches assigned', style: TextStyle(color: AppColors.textHint))
        else
          Wrap(
            spacing: AppDimensions.spacingS,
            children: batch.assignedCoaches.map((c) => Chip(
              label: Text(c.name, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.accent.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.accent),
              side: BorderSide.none,
            )).toList(),
          ),
          
        const SizedBox(height: AppDimensions.spacingL),
        SizedBox(
          width: double.infinity,
          child: NeumorphicContainer(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
            onTap: () {
              Navigator.of(context).pop();
              // Original implementation of viewing students
              _showBatchStudents(context, batch);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, color: AppColors.accent),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  widget.isOwner ? 'Manage Students' : 'View Students',
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBatchStudents(BuildContext context, Batch batch) {
    BatchStudentsSheet.show(context, batch);
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Batch Name',
            hint: 'e.g., Morning Batch A',
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildTimePickerRow(),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _capacityController,
                  label: 'Capacity',
                  hint: 'e.g., 20',
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: CustomTextField(
                  controller: _feesController,
                  label: 'Fees',
                  hint: 'e.g., 5000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildDatePicker(),
          const SizedBox(height: AppDimensions.spacingM),
          CustomTextField(
            controller: _locationController,
            label: 'Location (Optional)',
            hint: 'e.g., Court 1',
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const Text('Select Days', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: AppDimensions.spacingS),
          _buildDaySelector(),
          const SizedBox(height: AppDimensions.spacingL),
          const Text('Assign Coaches', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: AppDimensions.spacingS),
          _buildCoachSelector(),
          const SizedBox(height: AppDimensions.spacingL),
          _buildSessionSelector(),
        ],
      ),
    );
  }

  Widget _buildTimePickerRow() {
    return Row(
      children: [
        Expanded(
          child: NeumorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingS),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _startTime ?? TimeOfDay.now());
              if (time != null) setState(() => _startTime = time);
            },
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.spacingS),
                Text(_startTime?.format(context) ?? 'Start Time', 
                  style: TextStyle(color: _startTime != null ? AppColors.textPrimary : AppColors.textHint)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: NeumorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingS),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _endTime ?? TimeOfDay.now());
              if (time != null) setState(() => _endTime = time);
            },
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.spacingS),
                Text(_endTime?.format(context) ?? 'End Time', 
                  style: TextStyle(color: _endTime != null ? AppColors.textPrimary : AppColors.textHint)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingS),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _startDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _startDate = date);
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingM),
          Text(_startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Select start date',
            style: TextStyle(color: _startDate != null ? AppColors.textPrimary : AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Wrap(
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingS,
      children: days.map((day) => FilterChip(
        label: Text(day),
        selected: _selectedDays.contains(day),
        onSelected: (selected) {
          setState(() {
            if (selected) _selectedDays.add(day);
            else _selectedDays.remove(day);
          });
        },
        selectedColor: AppColors.accent,
        labelStyle: TextStyle(color: _selectedDays.contains(day) ? Colors.white : AppColors.textPrimary),
      )).toList(),
    );
  }

  Widget _buildCoachSelector() {
    if (_isLoadingCoaches) return const Center(child: CircularProgressIndicator());
    return Wrap(
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
                if (!_selectedCoachIds.contains(coach.id)) _selectedCoachIds.add(coach.id);
              } else {
                _selectedCoachIds.remove(coach.id);
              }
            });
          },
          selectedColor: AppColors.accent.withOpacity(0.3),
          checkmarkColor: AppColors.accent,
        );
      }).toList(),
    );
  }

  Widget _buildSessionSelector() {
    final sessionsAsync = ref.watch(activeSessionsProvider);
    return sessionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (sessions) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Session (Optional)', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: AppDimensions.spacingS),
          NeumorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            child: DropdownButtonFormField<int>(
              value: _selectedSessionId,
              decoration: const InputDecoration(border: InputBorder.none),
              dropdownColor: AppColors.cardBackground,
              items: [
                const DropdownMenuItem<int>(value: null, child: Text('No Session')),
                ...sessions.map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name))),
              ],
              onChanged: (val) => setState(() => _selectedSessionId = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (widget.batch == null) {
                  Navigator.of(context).pop();
                } else {
                  setState(() => _isEditing = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveBatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
