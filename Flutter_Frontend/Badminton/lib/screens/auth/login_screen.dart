import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/auth_provider.dart';

/// Login screen for user authentication
class LoginScreen extends ConsumerStatefulWidget {
  final String userType;

  const LoginScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            userType: widget.userType,
            rememberMe: _rememberMe,
          );

      if (mounted) {
        // Check profile completeness for students
        if (widget.userType == 'student') {
          final profileComplete = result['profile_complete'] ?? false;
          if (!profileComplete) {
            // Redirect to profile completion page
            context.go('/student-profile-complete');
            return;
          }
        }

        // Navigate to appropriate dashboard based on user type
        String route;
        switch (widget.userType) {
          case 'owner':
            route = '/owner-dashboard';
            break;
          case 'coach':
            route = '/coach-dashboard';
            break;
          case 'student':
            route = '/student-dashboard';
            break;
          default:
            route = '/';
        }
        context.go(route);
      }
    } catch (e) {
      if (mounted) {
        // Extract user-friendly error message
        String errorMessage = 'An error occurred. Please try again.';
        if (e.toString().contains('Exception: ')) {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        } else if (e.toString().isNotEmpty) {
          errorMessage = e.toString();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
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

  IconData _getRoleIcon() {
    switch (widget.userType) {
      case 'owner':
        return Icons.admin_panel_settings;
      case 'coach':
        return Icons.person_outline;
      case 'student':
        return Icons.school_outlined;
      default:
        return Icons.person;
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
                // Role Icon
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRoleIcon(),
                    size: 64,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Title
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.spacingS),

                // Subtitle
                Text(
                  'Sign in as ${_getRoleTitle()}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

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
                const SizedBox(height: AppDimensions.spacingL),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.spacingM),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Remember Me Checkbox
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() => _rememberMe = value ?? false);
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
                        Text(
                          'Remember Me',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),

                    // Forgot Password
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.push('/forgot-password', extra: widget.userType);
                            },
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.accent,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: NeumorphicButton(
                    text: _isLoading ? 'Signing In...' : 'Sign In',
                    onPressed: _isLoading ? null : _handleLogin,
                    isAccent: true,
                    icon: _isLoading ? null : Icons.login,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.push('/signup', extra: widget.userType);
                            },
                      child: Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
