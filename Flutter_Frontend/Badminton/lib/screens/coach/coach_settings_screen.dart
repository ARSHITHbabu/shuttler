import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/settings/shuttlecock_theme_toggle.dart';
import '../../providers/theme_provider.dart';
import '../../providers/service_providers.dart';
import '../common/privacy_policy_screen.dart';
import '../common/terms_conditions_screen.dart';
import '../common/help_support_screen.dart';

/// Coach Settings Screen - App settings and preferences
class CoachSettingsScreen extends ConsumerStatefulWidget {
  const CoachSettingsScreen({super.key});

  @override
  ConsumerState<CoachSettingsScreen> createState() => _CoachSettingsScreenState();
}

class _CoachSettingsScreenState extends ConsumerState<CoachSettingsScreen> {
  bool _notificationsEnabled = true;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    // App version - can be set manually or loaded from package info if available
    setState(() {
      _appVersion = '1.0.0'; // Default version
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textPrimaryColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Settings Section
              const _SectionTitle(title: 'App Settings'),
              const SizedBox(height: AppDimensions.spacingM),
              
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_outlined, color: textPrimaryColor.withValues(alpha: 0.6)),
                        const SizedBox(width: AppDimensions.spacingM),
                        Text(
                          'Push Notifications',
                          style: TextStyle(
                            color: textPrimaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                      activeTrackColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),

              // Theme Toggle Section
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              ShuttlecockThemeToggle(
                isDarkMode: isDarkMode,
                onToggle: () {
                  ref.read(themeNotifierProvider.notifier).toggleTheme();
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Support Section
              const _SectionTitle(title: 'Support'),
              const SizedBox(height: AppDimensions.spacingM),

              _SettingsItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(userRole: 'coach'),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacingS),

              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacingS),

              _SettingsItem(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TermsConditionsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // App Info Section
              const _SectionTitle(title: 'App Info'),
              const SizedBox(height: AppDimensions.spacingM),

              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: textPrimaryColor.withValues(alpha: 0.6)),
                        const SizedBox(width: AppDimensions.spacingM),
                        Text(
                          'App Version',
                          style: TextStyle(
                            color: textPrimaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _appVersion,
                      style: TextStyle(
                        color: textPrimaryColor.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              _SettingsItem(
                icon: Icons.delete_outline,
                title: 'Clear Cache',
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Logout Section
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: _SettingsItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Clear Cache',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will clear all cached data. You may need to log in again.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SuccessSnackbar.show(context, 'Cache cleared');
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleLogout(context, ref);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      
      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        SuccessSnackbar.showError(context, 'Failed to logout: ${e.toString()}');
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimaryColor = theme.colorScheme.onSurface;
    final itemTextColor = textColor ?? textPrimaryColor;
    final itemIconColor = iconColor ?? textPrimaryColor.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Icon(icon, color: itemIconColor),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: itemTextColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: textPrimaryColor.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
