import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';

/// Reusable dialog for changing password
class ChangePasswordDialog extends ConsumerStatefulWidget {
  final String userType; // 'owner', 'coach', or 'student'
  final String userEmail;

  const ChangePasswordDialog({
    super.key,
    required this.userType,
    required this.userEmail,
  });

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Clear error message and reset form validation state
  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleChangePassword() async {
    // Clear any previous error immediately - this ensures error state is reset
    // before any new validation or API call
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }

    // Validate form - this will show field-level errors if any
    if (!_formKey.currentState!.validate()) {
      // If validation fails, don't proceed - field errors will show
      return;
    }

    // Check if new password is different from current password
    if (_currentPasswordController.text == _newPasswordController.text) {
      if (mounted) {
        setState(() {
          _errorMessage = 'New password must be different from current password';
        });
      }
      return;
    }

    // Clear error and set loading state in one atomic update
    // This ensures error is cleared before API call
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });
    }

    try {
      final apiService = ref.read(apiServiceProvider);

      final response = await apiService.post(
        '/auth/change-password',
        data: {
          'email': widget.userEmail,
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
          'user_type': widget.userType,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          if (mounted) {
            // Show success message on the main screen after closing dialog
            Navigator.of(context).pop();
            // Use the root navigator to show snackbar on the main screen
            SuccessSnackbar.show(
              context,
              data['message'] ?? 'Password changed successfully',
            );
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to change password');
        }
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to change password';
        
        // Handle DioException to extract error message from response
        if (e is DioException) {
          // Check for response data first (most common case)
          if (e.response != null && e.response!.data != null) {
            final responseData = e.response!.data;
            if (responseData is Map<String, dynamic>) {
              // Extract fresh error message from API response
              errorMessage = responseData['message']?.toString() ?? 
                           responseData['error']?.toString() ?? 
                           'Failed to change password';
            } else if (responseData is String) {
              errorMessage = responseData;
            }
          } 
          // Handle different DioException types
          else if (e.type == DioExceptionType.connectionTimeout ||
                   e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Connection timeout. Please try again.';
          } else if (e.type == DioExceptionType.unknown) {
            errorMessage = 'Network error. Please check your connection.';
          } else {
            errorMessage = e.message ?? 'Failed to change password';
          }
        } else if (e is Exception) {
          final errorStr = e.toString();
          // Extract error message from exception string
          if (errorStr.contains('Current password is incorrect')) {
            errorMessage = 'Current password is incorrect';
          } else if (errorStr.contains('Exception:')) {
            errorMessage = errorStr.replaceAll('Exception: ', '').trim();
          } else {
            errorMessage = errorStr.trim();
          }
        } else {
          errorMessage = e.toString().trim();
        }
        
        // Set error message in state - this will trigger UI update
        // Ensure we're setting a fresh error, not reusing old state
        if (mounted) {
          setState(() {
            _errorMessage = errorMessage;
            _isLoading = false;
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textPrimaryColor = theme.colorScheme.onSurface;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Change Password',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textPrimaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: textPrimaryColor.withValues(alpha: 0.6),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Current Password Field
                  CustomTextField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    obscureText: _obscureCurrentPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon:
                        _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                      _clearError();
                    },
                    onChanged: (_) {
                      _clearError();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // New Password Field
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    hint: 'Enter your new password',
                    obscureText: _obscureNewPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon:
                        _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                      _clearError();
                    },
                    onChanged: (_) {
                      _clearError();
                    },
                    validator: Validators.validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Re-enter your new password',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                      _clearError();
                    },
                    onChanged: (_) {
                      _clearError();
                    },
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _newPasswordController.text,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _handleChangePassword();
                      }
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Error Message Display
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                  ],

                  const SizedBox(height: AppDimensions.spacingM),

                  // Change Password Button
                  NeumorphicButton(
                    text: _isLoading ? 'Changing Password...' : 'Change Password',
                    onPressed: _isLoading ? null : _handleChangePassword,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Cancel Button
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textPrimaryColor.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
