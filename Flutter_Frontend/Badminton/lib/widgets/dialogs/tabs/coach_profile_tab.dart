import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/success_snackbar.dart';
import '../../../widgets/common/confirmation_dialog.dart';
import '../../../providers/coach_provider.dart';
import '../../../models/coach.dart';
import '../../../core/utils/contact_utils.dart';
import 'package:intl/intl.dart';

/// Profile Tab - Shows coach information and management actions
class CoachProfileTab extends ConsumerStatefulWidget {
  final Coach coach;
  final VoidCallback? onCoachUpdated;

  const CoachProfileTab({
    super.key,
    required this.coach,
    this.onCoachUpdated,
  });

  @override
  ConsumerState<CoachProfileTab> createState() => _CoachProfileTabState();
}

class _CoachProfileTabState extends ConsumerState<CoachProfileTab> {
  CoachEditableField? _editingField;
  final TextEditingController _editController = TextEditingController();
  DateTime? _pendingJoiningDate;
  bool _isSavingInline = false;

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Contact Information
          _buildContactInfo(),
          
          const SizedBox(height: AppDimensions.spacingL),

          // Professional Information
          _buildProfessionalInfo(),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  void _startInlineEdit(CoachEditableField field) {
    setState(() {
      _editingField = field;
      _isSavingInline = false;
      _pendingJoiningDate = widget.coach.joiningDate;

      switch (field) {
        case CoachEditableField.email:
          _editController.text = widget.coach.email;
          break;
        case CoachEditableField.phone:
          _editController.text = widget.coach.phone;
          break;
        case CoachEditableField.specialization:
          _editController.text = widget.coach.specialization ?? '';
          break;
        case CoachEditableField.experienceYears:
          _editController.text = widget.coach.experienceYears?.toString() ?? '';
          break;
        case CoachEditableField.monthlySalary:
          _editController.text = widget.coach.monthlySalary?.toStringAsFixed(0) ?? '';
          break;
        case CoachEditableField.joiningDate:
          _editController.text = '';
          break;
      }
    });
  }

  void _cancelInlineEdit() {
    setState(() {
      _editingField = null;
      _isSavingInline = false;
      _pendingJoiningDate = null;
      _editController.clear();
    });
  }

  Future<void> _saveInlineEdit(CoachEditableField field) async {
    if (_isSavingInline) return;

    Map<String, dynamic> payload;
    final raw = _editController.text.trim();

    switch (field) {
      case CoachEditableField.email:
        payload = {'email': raw};
        break;
      case CoachEditableField.phone:
        payload = {'phone': raw};
        break;
      case CoachEditableField.specialization:
        payload = {'specialization': raw};
        break;
      case CoachEditableField.experienceYears:
        final parsed = int.tryParse(raw);
        if (parsed == null) {
          SuccessSnackbar.showError(context, 'Please enter a valid number for experience');
          return;
        }
        payload = {'experience_years': parsed};
        break;
      case CoachEditableField.monthlySalary:
        final parsed = double.tryParse(raw);
        if (parsed == null) {
          SuccessSnackbar.showError(context, 'Please enter a valid salary amount');
          return;
        }
        payload = {'monthly_salary': parsed};
        break;
      case CoachEditableField.joiningDate:
        final date = _pendingJoiningDate;
        if (date == null) {
          SuccessSnackbar.showError(context, 'Please select a joining date');
          return;
        }
        payload = {'joining_date': DateFormat('yyyy-MM-dd').format(date)};
        break;
    }

    setState(() => _isSavingInline = true);
    try {
      await ref.read(coachListProvider.notifier).updateCoach(widget.coach.id, payload);
      if (!mounted) return;
      ref.invalidate(coachByIdProvider(widget.coach.id));
      SuccessSnackbar.show(context, 'Coach updated successfully');
      widget.onCoachUpdated?.call();
      _cancelInlineEdit();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingInline = false);
      SuccessSnackbar.showError(context, 'Failed to update coach: ${e.toString()}');
    }
  }

  Future<void> _pickJoiningDate() async {
    final initial = _pendingJoiningDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(1990),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() => _pendingJoiningDate = picked);
  }

  Widget _buildProfileHeader() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.coach.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.coach.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.coach.status == 'active'
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    widget.coach.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            children: [
              if (widget.coach.email.isNotEmpty)
                _buildInfoRow(
                  Icons.email_outlined, 
                  'Email', 
                  widget.coach.email,
                  field: CoachEditableField.email,
                  onTap: _editingField == CoachEditableField.email
                      ? null
                      : () => ContactUtils.launchEmail(widget.coach.email),
                ),
              if (widget.coach.email.isNotEmpty && widget.coach.phone.isNotEmpty)
                const Divider(color: AppColors.textSecondary, height: 24),
              if (widget.coach.phone.isNotEmpty)
                _buildInfoRow(
                  Icons.phone_outlined, 
                  'Phone', 
                  widget.coach.phone,
                  field: CoachEditableField.phone,
                  onTap: _editingField == CoachEditableField.phone
                      ? null
                      : () => ContactUtils.showContactOptions(context, widget.coach.phone, name: widget.coach.name),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalInfo() {
    if (widget.coach.specialization == null && widget.coach.experienceYears == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            children: [
              if (widget.coach.specialization != null && widget.coach.specialization!.isNotEmpty)
                _buildInfoRow(
                  Icons.sports_tennis_outlined,
                  'Specialization',
                  widget.coach.specialization!,
                  field: CoachEditableField.specialization,
                ),
              if (widget.coach.specialization != null && widget.coach.experienceYears != null)
                const Divider(color: AppColors.textSecondary, height: 24),
              if (widget.coach.experienceYears != null)
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Experience',
                  '${widget.coach.experienceYears} years',
                  field: CoachEditableField.experienceYears,
                ),
              const Divider(color: AppColors.textSecondary, height: 24),
              _buildInfoRow(
                Icons.attach_money, 
                'Monthly Salary', 
                widget.coach.monthlySalary != null ? '\$${widget.coach.monthlySalary!.toStringAsFixed(0)}' : 'Not Set',
                field: CoachEditableField.monthlySalary,
              ),
              const Divider(color: AppColors.textSecondary, height: 24),
              _buildInfoRow(
                Icons.date_range, 
                'Joining Date', 
                widget.coach.joiningDate != null 
                    ? DateFormat('dd MMM, yyyy').format(widget.coach.joiningDate!)
                    : 'Not Set',
                field: CoachEditableField.joiningDate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _toggleStatus(),
            icon: Icon(
              widget.coach.status == 'active' ? Icons.person_off : Icons.person,
              size: 18,
            ),
            label: Text(widget.coach.status == 'active' ? 'Mark Inactive' : 'Mark Active'),
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.coach.status == 'active' 
                  ? AppColors.error 
                  : AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _deleteCoach(),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete Coach'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap, required CoachEditableField field}) {
    final isEditing = _editingField == field;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                if (!isEditing)
                  onTap != null
                      ? InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.accent.withOpacity(0.5),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _InlineEditor(
                          field: field,
                          controller: _editController,
                          pendingJoiningDate: _pendingJoiningDate,
                          isSaving: _isSavingInline,
                          onPickDate: _pickJoiningDate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 72,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: 'Save $label',
                              onPressed: _isSavingInline ? null : () => _saveInlineEdit(field),
                              icon: Icon(
                                Icons.check,
                                size: 18,
                                color: _isSavingInline ? AppColors.textTertiary : AppColors.success,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: 'Cancel',
                              onPressed: _isSavingInline ? null : _cancelInlineEdit,
                              icon: Icon(
                                Icons.close,
                                size: 18,
                                color: _isSavingInline ? AppColors.textTertiary : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!isEditing)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Edit $label',
              onPressed: () => _startInlineEdit(field),
              icon: Icon(
                Icons.edit,
                size: 16,
                color: AppColors.textTertiary.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleStatus() async {
    try {
      final newStatus = widget.coach.status == 'active' ? 'inactive' : 'active';
      await ref.read(coachListProvider.notifier).updateCoach(widget.coach.id, {'status': newStatus});
      if (mounted) {
        SuccessSnackbar.show(context, 'Coach ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully');
        widget.onCoachUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to update coach status: ${e.toString()}');
      }
    }
  }

  void _deleteCoach() {
    ConfirmationDialog.showDelete(
      context,
      widget.coach.name,
      onConfirm: () async {
        try {
          await ref.read(coachListProvider.notifier).deleteCoach(widget.coach.id);
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog
            // Also close the details dialog since the coach is deleted
            Navigator.of(context).pop(); 
            SuccessSnackbar.show(context, 'Coach deleted successfully');
          }
        } catch (e) {
          if (mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete coach: ${e.toString()}');
          }
        }
      },
    );
  }
}

enum CoachEditableField {
  email,
  phone,
  specialization,
  experienceYears,
  monthlySalary,
  joiningDate,
}

class _InlineEditor extends StatelessWidget {
  final CoachEditableField field;
  final TextEditingController controller;
  final DateTime? pendingJoiningDate;
  final bool isSaving;
  final VoidCallback onPickDate;

  const _InlineEditor({
    required this.field,
    required this.controller,
    required this.pendingJoiningDate,
    required this.isSaving,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    if (field == CoachEditableField.joiningDate) {
      final display = pendingJoiningDate != null ? DateFormat('dd MMM, yyyy').format(pendingJoiningDate!) : 'Select date';
      return Row(
        children: [
          Expanded(
            child: Text(
              display,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: isSaving ? null : onPickDate,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: const Text('Pick'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
        ],
      );
    }

    TextInputType keyboardType = TextInputType.text;
    switch (field) {
      case CoachEditableField.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case CoachEditableField.phone:
        keyboardType = TextInputType.phone;
        break;
      case CoachEditableField.experienceYears:
        keyboardType = TextInputType.number;
        break;
      case CoachEditableField.monthlySalary:
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
        break;
      case CoachEditableField.specialization:
      case CoachEditableField.joiningDate:
        keyboardType = TextInputType.text;
        break;
    }

    return TextField(
      controller: controller,
      enabled: !isSaving,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        hintText: 'Enter ${
            field == CoachEditableField.experienceYears
                ? 'years'
                : field == CoachEditableField.monthlySalary
                    ? 'salary'
                    : field.name
          }',
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }
}
