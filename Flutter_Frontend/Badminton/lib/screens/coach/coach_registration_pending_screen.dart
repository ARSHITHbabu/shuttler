import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../providers/service_providers.dart';

class CoachRegistrationPendingScreen extends ConsumerStatefulWidget {
  final String email;

  const CoachRegistrationPendingScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<CoachRegistrationPendingScreen> createState() => _CoachRegistrationPendingScreenState();
}

class _CoachRegistrationPendingScreenState extends ConsumerState<CoachRegistrationPendingScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    try {
      final service = ref.read(coachRegistrationRequestServiceProvider);
      final status = await service.checkStatus(widget.email);
      
      if (mounted) {
        if (status['exists'] == true) {
          final requestStatus = status['status'] as String;
          
          if (requestStatus == 'approved') {
            // Show success message and redirect to login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your coach registration has been approved! Please login.'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 5),
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                context.go('/login', extra: 'coach');
              }
            });
          } else if (requestStatus == 'rejected') {
            // Show rejection message
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cardBackground
                    : AppColorsLight.cardBackground,
                title: Text(
                  'Registration Rejected',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimary
                        : AppColorsLight.textPrimary,
                  ),
                ),
                content: Text(
                  status['review_notes'] as String? ?? 
                  'Your coach registration request has been rejected. Please contact the academy for more information.',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/');
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.accent
                            : AppColorsLight.accent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Still pending
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your coach registration is still pending approval.'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No registration request found for this email.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeumorphicContainer(
                width: 120,
                height: 120,
                borderRadius: 60,
                child: const Icon(
                  Icons.pending_outlined,
                  size: 64,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              Text(
                'Coach Registration Pending',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              Text(
                'Your coach registration request has been submitted successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Expanded(
                          child: Text(
                            'What happens next?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'The academy owner will review your application. You will be able to log in once your application is approved.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Email: ${widget.email}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              NeumorphicButton(
                text: _isChecking ? 'Checking...' : 'Check Status',
                onPressed: _isChecking ? null : _checkStatus,
                icon: Icons.refresh,
              ),
              const SizedBox(height: AppDimensions.spacingM),

              TextButton(
                onPressed: () => context.go('/login', extra: 'coach'),
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    color: isDark ? AppColors.accent : AppColorsLight.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
