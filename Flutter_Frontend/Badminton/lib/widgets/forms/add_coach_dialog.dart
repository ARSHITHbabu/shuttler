import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/neumorphic_button.dart';

/// Dialog for adding a new coach
class AddCoachDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddCoachDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddCoachDialog> createState() => _AddCoachDialogState();
}

class _AddCoachDialogState extends State<AddCoachDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
        'password': _passwordController.text.trim(),
        'role': 'coach',
        if (_specializationController.text.trim().isNotEmpty)
          'specialization': _specializationController.text.trim(),
        if (_experienceController.text.trim().isNotEmpty)
          'experience_years': int.tryParse(_experienceController.text.trim()),
      };

      await widget.onSubmit(coachData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coach added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Coach',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                _buildTextField(
                  controller: _nameController,
                  label: 'Coach Name *',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter coach name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number *',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address *',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password *',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildTextField(
                  controller: _specializationController,
                  label: 'Specialization (Optional)',
                  icon: Icons.sports_tennis_outlined,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildTextField(
                  controller: _experienceController,
                  label: 'Experience Years (Optional)',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppDimensions.spacingL),
                NeumorphicButton(
                  text: _isLoading ? 'Adding...' : 'Add Coach',
                  onPressed: _isLoading ? null : _handleSubmit,
                  isAccent: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return NeumorphicInsetContainer(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.iconPrimary, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
