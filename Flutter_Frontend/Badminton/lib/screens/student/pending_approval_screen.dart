import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/service_providers.dart';

/// Pending Approval Screen
/// Shown to students whose accounts are pending owner approval
class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() =>
      _PendingApprovalScreenState();
}

class _PendingApprovalScreenState
    extends ConsumerState<PendingApprovalScreen> {
  bool _isRefreshing = false;

  Future<void> _checkStatus() async {
    setState(() => _isRefreshing = true);
    try {
      final authState = ref.read(authProvider);
      authState.whenData((authValue) async {
        if (authValue is Authenticated && authValue.userType == 'student') {
          // Invalidate student provider to force refresh
          ref.invalidate(studentByIdProvider(authValue.userId));
          
          // Wait a bit for the refresh
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Check status again
          final student = await ref.read(
            studentByIdProvider(authValue.userId).future,
          );
          
          if (student.status == 'active' && mounted) {
            // Status changed to active, redirect to dashboard
            context.go('/student-dashboard');
          }
        }
      });
    } catch (e) {
      // Error checking status, ignore
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = isDark
        ? AppColors.surfaceLight
        : AppColorsLight.surfaceLight;
    final shadowColor = isDark
        ? AppColors.shadowDark
        : AppColorsLight.shadowDark;

    final authStateAsync = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradient
              : AppColorsLight.backgroundGradient,
        ),
        child: SafeArea(
          child: authStateAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading account status',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeumorphicButton(
                    onPressed: _handleLogout,
                    text: 'Go to Login',
                    icon: Icons.login,
                  ),
                ],
              ),
            ),
            data: (authState) {
              if (authState is! Authenticated ||
                  authState.userType != 'student') {
                // Not a student, redirect to login
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go('/');
                });
                return const SizedBox.shrink();
              }

              final userId = authState.userId;
              final studentAsync = ref.watch(studentByIdProvider(userId));

              return studentAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading account information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      NeumorphicButton(
                        onPressed: _handleLogout,
                        text: 'Go to Login',
                        icon: Icons.login,
                      ),
                    ],
                  ),
                ),
                data: (student) {
                  // If status is active, redirect to dashboard
                  if (student.status == 'active') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go('/student-dashboard');
                    });
                    return const SizedBox.shrink();
                  }

                  // Show pending approval UI
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Pending Icon with Animation
                        NeumorphicContainer(
                          width: 120,
                          height: 120,
                          child: const Icon(
                            Icons.pending_actions,
                            size: 64,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Title
                        Text(
                          'Account Pending Approval',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          'Your account registration is currently under review by the academy owner.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You will be notified once your account has been approved.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        // Student Info Card
                        NeumorphicContainer(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Account Information',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                context,
                                'Name',
                                student.name,
                                Icons.badge_outlined,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                context,
                                'Email',
                                student.email,
                                Icons.email_outlined,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                context,
                                'Phone',
                                student.phone,
                                Icons.phone_outlined,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                context,
                                'Status',
                                'Pending Approval',
                                Icons.pending_outlined,
                                valueColor: AppColors.warning,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Refresh Button
                        NeumorphicButton(
                          onPressed: _isRefreshing ? null : _checkStatus,
                          text: _isRefreshing
                              ? 'Checking Status...'
                              : 'Check Status',
                          icon: _isRefreshing
                              ? Icons.refresh
                              : Icons.refresh_outlined,
                          isLoading: _isRefreshing,
                        ),
                        const SizedBox(height: 24),
                        // Logout Button
                        NeumorphicButton(
                          onPressed: _handleLogout,
                          text: 'Logout',
                          icon: Icons.logout,
                          isOutlined: true,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
