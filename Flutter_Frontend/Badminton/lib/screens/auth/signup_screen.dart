import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/service_providers.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/password_strength_indicator.dart';

/// Signup screen for user registration
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  
  String _selectedRole = 'student'; // 'student' or 'coach'
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedRole == 'student') {
        // For students, create registration request instead of direct account
        final requestService = ref.read(studentRegistrationRequestServiceProvider);
        
        await requestService.createRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          context.go('/student-registration-pending', extra: _emailController.text.trim());
        }
      } else {
        // For coaches, create registration request
        final coachRequestService = ref.read(coachRegistrationRequestServiceProvider);
        
        await coachRequestService.createRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          specialization: _specializationController.text.trim(),
          experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
        );

        if (mounted) {
          context.go('/coach-registration-pending', extra: _emailController.text.trim());
        }
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: AppLogo(
                    height: 80,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                
                // Creative Role Selector
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXs),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    boxShadow: NeumorphicStyles.getInsetShadow(),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _RoleToggleButton(
                          isSelected: _selectedRole == 'student',
                          label: 'Student',
                          icon: Icons.school_outlined,
                          onTap: () => setState(() => _selectedRole = 'student'),
                        ),
                      ),
                      Expanded(
                        child: _RoleToggleButton(
                          isSelected: _selectedRole == 'coach',
                          label: 'Coach',
                          icon: Icons.sports_tennis,
                          onTap: () => setState(() => _selectedRole = 'coach'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.validateName,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Phone Field
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: Validators.validatePhone,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Dynamic Coach Fields
                if (_selectedRole == 'coach') ...[
                  CustomTextField(
                    controller: _specializationController,
                    label: 'Specialization',
                    hint: 'e.g., Singles, Footwork',
                    prefixIcon: Icons.star_outline,
                    validator: (v) => _selectedRole == 'coach' && (v == null || v.isEmpty) 
                        ? 'Specialization is required' 
                        : null,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  CustomTextField(
                    controller: _experienceController,
                    label: 'Experience (Years)',
                    hint: 'Number of years',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.history_outlined,
                    validator: (v) => _selectedRole == 'coach' && (v == null || v.isEmpty)
                        ? 'Experience is required'
                        : null,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                ],

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Create a password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.validatePassword,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.spacingS),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _passwordController,
                  builder: (context, value, child) {
                    return PasswordStrengthIndicator(password: value.text);
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) =>
                      Validators.validateConfirmPassword(value, _passwordController.text),
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppDimensions.spacingM),

                // Terms & Conditions
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() => _acceptTerms = value ?? false);
                              },
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.accent;
                          }
                          return AppColors.cardBackground;
                        }),
                        checkColor: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Text(
                        'I accept the Terms & Conditions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Signup Button
                SizedBox(
                  width: double.infinity,
                  child: NeumorphicButton(
                    text: _isLoading ? 'Creating Account...' : 'Create Account',
                    onPressed: _isLoading ? null : _handleSignup,
                    isAccent: true,
                    icon: _isLoading ? null : Icons.person_add,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.pop();
                            },
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),

                // Loading Indicator
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: AppDimensions.spacingL),
                    child: Center(
                      child: LoadingSpinner(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleToggleButton extends StatelessWidget {
  final bool isSelected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleToggleButton({
    required this.isSelected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: isSelected ? NeumorphicStyles.getElevatedShadow() : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
