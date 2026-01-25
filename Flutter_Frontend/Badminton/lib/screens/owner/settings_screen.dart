import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/settings/shuttlecock_theme_toggle.dart';
import '../common/privacy_policy_screen.dart';
import '../common/terms_conditions_screen.dart';
import '../common/help_support_screen.dart';
import 'profile_screen.dart';
import 'academy_details_screen.dart';

/// Settings Screen - App settings, academy settings, account settings
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

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

              // Account Settings Section
              const _SectionTitle(title: 'Account'),
              const SizedBox(height: AppDimensions.spacingM),

              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),

              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  // TODO: Navigate to change password
                  SuccessSnackbar.showInfo(context, 'Change password feature coming soon');
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Academy Settings Section
              const _SectionTitle(title: 'Academy'),
              const SizedBox(height: AppDimensions.spacingM),

              _SettingsTile(
                icon: Icons.business_outlined,
                title: 'Academy Details',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AcademyDetailsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Data & Storage Section
              const _SectionTitle(title: 'Data & Storage'),
              const SizedBox(height: AppDimensions.spacingM),

              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Export Data',
                onTap: () {
                  // TODO: Export data
                  SuccessSnackbar.showInfo(context, 'Export data feature coming soon');
                },
              ),

              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear Cache',
                onTap: () async {
                  final confirm = await ConfirmationDialog.show(
                    context,
                    'Clear Cache',
                    'Are you sure you want to clear all cached data?',
                    confirmText: 'Clear',
                    cancelText: 'Cancel',
                    icon: Icons.delete_outline,
                    isDestructive: true,
                  );
                  if (confirm == true && mounted) {
                    // TODO: Clear cache
                    SuccessSnackbar.show(context, 'Cache cleared');
                  }
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // About Section
              const _SectionTitle(title: 'About'),
              const SizedBox(height: AppDimensions.spacingM),

              _SettingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: null,
              ),

              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(userRole: 'owner'),
                    ),
                  );
                },
              ),

              _SettingsTile(
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

              _SettingsTile(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final textSecondaryColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textSecondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimaryColor = theme.colorScheme.onSurface;
    final textSecondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: textSecondaryColor, size: 24),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: textSecondaryColor,
              size: 20,
            ),
        ],
      ),
    );
  }
}
