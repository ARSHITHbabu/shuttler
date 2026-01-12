import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../models/coach.dart';

/// Dialog for editing coach details
class EditCoachDialog extends StatefulWidget {
  final Coach coach;
  final Function(Map<String, dynamic>)? onSubmit;

  const EditCoachDialog({
    super.key,
    required this.coach,
    this.onSubmit,
  });

  @override
  State<EditCoachDialog> createState() => _EditCoachDialogState();
}

class _EditCoachDialogState extends State<EditCoachDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _specializationController;
  late final TextEditingController _experienceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.coach.name);
    _phoneController = TextEditingController(text: widget.coach.phone);
    _emailController = TextEditingController(text: widget.coach.email);
    _specializationController = TextEditingController(text: widget.coach.specialization ?? '');
    _experienceController = TextEditingController(
      text: widget.coach.experienceYears?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final coachData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'specialization': _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        'experience_years': _experienceController.text.trim().isEmpty
            ? null
            : int.tryParse(_experienceController.text.trim()),
      };

      if (widget.onSubmit != null) {
        await widget.onSubmit!(coachData);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coach updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update coach: $e')),
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
                  'Edit Coach',
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
                  hint: 'Enter coach name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter coach name';
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
                  controller: _specializationController,
                  label: 'Specialization (Optional)',
                  hint: 'Enter specialization',
                ),
                const SizedBox(height: AppDimensions.spacingM),
                CustomTextField(
                  controller: _experienceController,
                  label: 'Experience Years (Optional)',
                  hint: 'Enter years of experience',
                  keyboardType: TextInputType.number,
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
