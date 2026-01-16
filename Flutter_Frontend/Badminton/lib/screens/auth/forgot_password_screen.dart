import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

/// Forgot Password Screen - Request password reset
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String userType;

  const ForgotPasswordScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _tokenReceived = false;
  String? _resetToken;
  final _resetTokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _resetTokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService(StorageService());
      final response = await apiService.post(
        '/auth/forgot-password',
        data: {
          'email': _emailController.text.trim(),
          'user_type': widget.userType,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Store reset token if provided (for development/testing)
          if (data.containsKey('reset_token')) {
            setState(() {
              _resetToken = data['reset_token'];
              _tokenReceived = true;
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Password reset token sent'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to request password reset');
        }
      } else {
        throw Exception('Failed to request password reset');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService(StorageService());
      final response = await apiService.post(
        '/auth/reset-password',
        data: {
          'email': _emailController.text.trim(),
          'reset_token': _resetTokenController.text.trim(),
          'new_password': _newPasswordController.text,
          'user_type': widget.userType,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Password reset successfully'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
              ),
            );
            // Navigate back to login
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                context.pop();
              }
            });
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to reset password');
        }
      } else {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 64,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Title
                Text(
                  _tokenReceived ? 'Reset Password' : 'Forgot Password',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.spacingS),

                // Subtitle
                Text(
                  _tokenReceived
                      ? 'Enter your reset token and new password'
                      : 'Enter your email to receive a password reset token',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                if (!_tokenReceived) ...[
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.validateEmail,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingXxl),

                  // Request Reset Button
                  NeumorphicButton(
                    text: _isLoading ? 'Sending...' : 'Send Reset Token',
                    onPressed: _isLoading ? null : _requestReset,
                    isAccent: true,
                    icon: _isLoading ? null : Icons.send,
                  ),
                ] else ...[
                  // Reset Token Field
                  CustomTextField(
                    controller: _resetTokenController,
                    label: 'Reset Token',
                    hint: 'Enter the reset token you received',
                    prefixIcon: Icons.key,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Reset token is required';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // New Password Field
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    hint: 'Enter your new password',
                    obscureText: _obscureNewPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureNewPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixIconTap: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your new password',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixIconTap: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingXxl),

                  // Reset Password Button
                  NeumorphicButton(
                    text: _isLoading ? 'Resetting...' : 'Reset Password',
                    onPressed: _isLoading ? null : _resetPassword,
                    isAccent: true,
                    icon: _isLoading ? null : Icons.check_circle,
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Back to Request Token
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _tokenReceived = false;
                              _resetTokenController.clear();
                              _newPasswordController.clear();
                              _confirmPasswordController.clear();
                            });
                          },
                    child: const Text(
                      'Back to request token',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),

                  // Show token if received (for development/testing)
                  if (_resetToken != null) ...[
                    const SizedBox(height: AppDimensions.spacingL),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reset Token (for testing):',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            _resetToken!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: AppDimensions.spacingL),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
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
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Loading Overlay
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
