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
import '../../providers/auth_provider.dart';

/// Signup screen for user registration
class SignupScreen extends ConsumerStatefulWidget {
  final String userType;
  final String? invitationToken;

  const SignupScreen({
    super.key,
    required this.userType,
    this.invitationToken,
  });

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
  bool _acceptTerms = false;
  bool _isLoading = false;
  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      // Prepare additional data for students (blood group)
      Map<String, dynamic>? additionalData;
      if (widget.userType == 'student' && _selectedBloodGroup != null) {
        additionalData = {'blood_group': _selectedBloodGroup};
      }

      await ref
          .read(authProvider.notifier)
          .register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            userType: widget.userType,
            additionalData: additionalData,
            invitationToken: widget.invitationToken,
          );

      if (mounted) {
        // Show success message
        SuccessSnackbar.show(
          context,
          widget.invitationToken != null
              ? 'Account created successfully! You can now log in.'
              : 'Account created successfully! Your registration request has been sent to the owner for approval. You will be able to log in once approved.',
        );
        
        // Redirect to login screen
        context.go('/login', extra: widget.userType);
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getRoleTitle() {
    switch (widget.userType) {
      case 'owner':
        return 'Owner';
      case 'coach':
        return 'Coach';
      case 'student':
        return 'Student';
      default:
        return 'User';
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'Sign Up as ${_getRoleTitle()}',
          style: const TextStyle(color: AppColors.textPrimary),
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
                const SizedBox(height: AppDimensions.spacingM),

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
                const SizedBox(height: AppDimensions.spacingL),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                ),
                // Blood Group Field (only for students, optional)
                if (widget.userType == 'student') ...[
                  const SizedBox(height: AppDimensions.spacingL),
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    decoration: InputDecoration(
                      labelText: 'Blood Group (Optional)',
                      hintText: 'Select your blood group',
                      prefixIcon: const Icon(
                        Icons.bloodtype_outlined,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      hintStyle: const TextStyle(color: AppColors.textHint),
                    ),
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: _bloodGroups.map((String group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (String? newValue) {
                            setState(() {
                              _selectedBloodGroup = newValue;
                            });
                          },
                  ),
                ],
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
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/login', extra: widget.userType);
                              }
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
                    child: Center(child: LoadingSpinner()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
