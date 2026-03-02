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
import '../../providers/service_providers.dart';
import '../../widgets/common/app_logo.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

/// Login screen for user authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

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
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final storageService = ref.read(storageServiceProvider);
    
    // Check if the user opted in previously
    final enabled = storageService.getBiometricEnabled();
    setState(() {
      _isBiometricEnabled = enabled;
    });

    try {
      final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canAuthenticate;
      });

      // Auto-prompt if biometrics is already fully enabled
      if (enabled && canAuthenticate) {
        _handleBiometricLogin();
      }
    } on PlatformException catch (e) {
      debugPrint("Biometrics error: $e");
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to sign in to your Badminton account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final storageService = ref.read(storageServiceProvider);
        final keys = await storageService.getBiometricCredentials();
        if (keys != null) {
          _emailController.text = keys['email']!;
          _passwordController.text = keys['password']!;
          _handleLogin(fromBiometric: true);
        } else {
          // Tokens missing for some reason
          setState(() {
            _isBiometricEnabled = false;
          });
          await storageService.setBiometricEnabled(false);
        }
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        // No biometrics enrolled
        debugPrint('No biometrics enrolled');
      } else if (e.code == auth_error.lockedOut || e.code == auth_error.permanentlyLockedOut) {
        // Locked out
        debugPrint('Biometrics locked out');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin({bool fromBiometric = false}) async {
    if (!fromBiometric && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );

      if (mounted) {
        // Offer biometric enablement on successful normal login if biometrics is natively supported but not yet enabled.
        if (!fromBiometric && _canCheckBiometrics && !_isBiometricEnabled) {
          final storageService = ref.read(storageServiceProvider);
          // Auto-enable biometrics and save encrypted payload natively.
          await storageService.saveBiometricCredentials(_emailController.text.trim(), _passwordController.text);
        }

        // Check for inactive account (NEW)
        if (result['account_inactive'] == true) {
          final rejoinPending = result['rejoin_request_pending'] ?? false;
          final studentId = result['student_id'];
          _showInactiveAccountDialog(context, studentId, rejoinPending);
          return;
        }

        final userType = result['userType'];
        
        // Check profile completeness for students
        if (userType == 'student') {
          final profileComplete = result['profile_complete'] ?? false;
          if (!profileComplete) {
            context.go('/student-profile-complete');
            return;
          }
        }

        // Navigate based on user type
        String route;
        switch (userType) {
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Icon
                const Center(
                  child: AppLogo(
                    height: 120,
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
                  'Sign in to your account',
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
                              context.push('/forgot-password');
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
                    onPressed: _isLoading ? null : () => _handleLogin(),
                    isAccent: true,
                    icon: _isLoading ? null : Icons.login,
                  ),
                ),
                
                // Show Biometric shortcut if it's available and user has setup their credentials
                if (_canCheckBiometrics && _isBiometricEnabled) ...[
                  const SizedBox(height: AppDimensions.spacingM),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.fingerprint, color: AppColors.accent),
                      label: const Text(
                        'Login with Biometrics', 
                        style: TextStyle(color: AppColors.textPrimary)
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColors.textSecondary.withValues(alpha: 0.3)
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleBiometricLogin,
                    ),
                  ),
                ],
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
                              context.push('/signup');
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

  void _showInactiveAccountDialog(BuildContext context, int studentId, bool isPending) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Account Inactive', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your account has been marked as inactive.',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isPending
                  ? 'Your rejoin request is currently pending owner approval. We will notify you once it\'s approved.'
                  : 'You can request to rejoin the academy. Once requested, the owner will review and approve your reactivation.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!isPending)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleRequestRejoin(studentId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: const Text('Request to Rejoin'),
            ),
        ],
      ),
    );
  }

  Future<void> _handleRequestRejoin(int studentId) async {
    setState(() => _isLoading = true);
    try {
      final studentService = ref.read(studentServiceProvider);
      await studentService.requestRejoin(studentId);
      if (mounted) {
        SuccessSnackbar.show(context, 'Rejoin request sent successfully! Please wait for owner approval.');
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to request rejoin: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
