import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../models/student.dart';
import '../../providers/service_providers.dart';
import '../../models/batch.dart';

/// Dialog for editing student details
class EditStudentDialog extends ConsumerStatefulWidget {
  final Student student;
  final Function(Map<String, dynamic>)? onSubmit;

  const EditStudentDialog({
    super.key,
    required this.student,
    this.onSubmit,
  });

  @override
  ConsumerState<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends ConsumerState<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _guardianNameController;
  late final TextEditingController _guardianPhoneController;
  int? _selectedBatchId;
  List<Batch> _batches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _phoneController = TextEditingController(text: widget.student.phone);
    _emailController = TextEditingController(text: widget.student.email);
    _guardianNameController = TextEditingController(text: widget.student.guardianName ?? '');
    _guardianPhoneController = TextEditingController(text: widget.student.guardianPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final studentData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'guardian_name': _guardianNameController.text.trim().isEmpty
            ? null
            : _guardianNameController.text.trim(),
        'guardian_phone': _guardianPhoneController.text.trim().isEmpty
            ? null
            : _guardianPhoneController.text.trim(),
      };

      if (widget.onSubmit != null) {
        await widget.onSubmit!(studentData);
      }

      // Assign to batch if selected
      if (_selectedBatchId != null && mounted) {
        try {
          final batchService = ref.read(batchServiceProvider);
          await batchService.enrollStudent(_selectedBatchId!, widget.student.id);
        } catch (e) {
          // Log error but don't fail the update
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Student updated but batch assignment failed: $e')),
            );
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update student: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Student',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                CustomTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Enter student name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter student name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  hint: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                CustomTextField(
                  controller: _guardianNameController,
                  label: 'Guardian Name (Optional)',
                  hint: 'Enter guardian name',
                ),
                const SizedBox(height: AppDimensions.spacingM),
                CustomTextField(
                  controller: _guardianPhoneController,
                  label: 'Guardian Phone (Optional)',
                  hint: 'Enter guardian phone',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                // Batch Selection
                NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: DropdownButtonFormField<int>(
                    value: _selectedBatchId,
                    decoration: const InputDecoration(
                      labelText: 'Assign to Batch (Optional)',
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
                      ..._batches.map((batch) {
                        return DropdownMenuItem<int>(
                          value: batch.id,
                          child: Text(batch.batchName),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _selectedBatchId = value),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
