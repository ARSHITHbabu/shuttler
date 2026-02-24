import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/settings/shuttlecock_theme_toggle.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/owner_provider.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/forms/change_password_dialog.dart';
import '../common/privacy_policy_screen.dart';
import '../common/terms_conditions_screen.dart';
import '../common/help_support_screen.dart';
import 'profile_screen.dart';
import 'academy_details_screen.dart';
import 'owner_management_screen.dart';

/// Settings Screen - App settings, academy settings, account settings
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;

  static const String _settingsKey = 'owner_settings';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final settingsJson = await storageService.getString(_settingsKey);
      if (settingsJson != null && mounted) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        setState(() {
          _pushNotifications = settings['push_notifications'] ?? true;
          _emailNotifications = settings['email_notifications'] ?? true;
        });
      }
    } catch (e) {
      // Use defaults
    }
  }

  Future<void> _saveSettings() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final settings = {
        'push_notifications': _pushNotifications,
        'email_notifications': _emailNotifications,
      };
      await storageService.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  // Theme Section
                  Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
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

                  // Account Section
                  _buildSection(
                    title: 'Account',
                    icon: Icons.account_circle_outlined,
                    isDark: isDark,
                    children: [
                      _buildActionTile(
                        title: 'Profile',
                        icon: Icons.person_outline,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        title: 'Change Password',
                        icon: Icons.lock_outline,
                        isDark: isDark,
                        onTap: () => _showChangePassword(isDark),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Notifications Section
                  _buildSection(
                    title: 'Notifications',
                    icon: Icons.notifications_outlined,
                    isDark: isDark,
                    children: [
                      _buildSwitchTile(
                        title: 'Push Notifications',
                        subtitle: 'Receive push notifications',
                        value: _pushNotifications,
                        onChanged: (value) {
                          setState(() => _pushNotifications = value);
                          _saveSettings();
                        },
                        isDark: isDark,
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'Email Notifications',
                        subtitle: 'Receive notifications via email',
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() => _emailNotifications = value);
                          _saveSettings();
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Academy Section
                  _buildSection(
                    title: 'Academy',
                    icon: Icons.business_outlined,
                    isDark: isDark,
                    children: [
                      _buildActionTile(
                        title: 'Academy Details',
                        icon: Icons.business_outlined,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AcademyDetailsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        title: 'Owner Management',
                        icon: Icons.people_outline,
                        isDark: isDark,
                        onTap: () {
                          // Navigate to Owner Management Screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const OwnerManagementScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // About Section
                  _buildSection(
                    title: 'About',
                    icon: Icons.info_outline,
                    isDark: isDark,
                    children: [
                      _buildInfoTile(
                        title: 'App Version',
                        value: '1.0.0',
                        isDark: isDark,
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        title: 'Privacy Policy',
                        icon: Icons.privacy_tip_outlined,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        title: 'Terms of Service',
                        icon: Icons.description_outlined,
                        isDark: isDark,
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

                  const SizedBox(height: AppDimensions.spacingL),

                  // Data & Storage Section
                  _buildSection(
                    title: 'Data & Storage',
                    icon: Icons.storage_outlined,
                    isDark: isDark,
                    children: [
                      _buildActionTile(
                        title: 'Export Data',
                        icon: Icons.download_outlined,
                        isDark: isDark,
                        onTap: () {
                          SuccessSnackbar.showInfo(context, 'Export data feature coming soon');
                        },
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        title: 'Clear Cache',
                        icon: Icons.delete_outline,
                        isDark: isDark,
                        isDestructive: true,
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
                            SuccessSnackbar.show(context, 'Cache cleared');
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // App Branding
                  _buildAppBranding(isDark),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // Contact Support at the very end as a premium card
                  _buildSupportCard(isDark),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(bool isDark) {
    final accentColor = isDark ? AppColors.accent : AppColorsLight.accent;
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  Icons.support_agent_outlined,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Help?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      'Contact our support team',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(userRole: 'owner'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  elevation: 0,
                ),
                child: const Text('Support'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Section Content
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColorsLight.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              boxShadow: NeumorphicStyles.getSmallInsetShadow(),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return isDark ? AppColors.accent : AppColorsLight.accent;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? (isDark ? AppColors.error : AppColorsLight.error)
                  : (isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? (isDark ? AppColors.error : AppColorsLight.error)
                      : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBranding(bool isDark) {
    return Column(
      children: [
        const AppLogo(
          height: 80,
        ),
        const SizedBox(height: AppDimensions.spacingM),
        ref.watch(activeOwnerProvider).when(
              data: (owner) => Text(
                owner?.academyName ?? 'Pursue Badminton',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
              loading: () => const SizedBox(height: 20),
              error: (_, __) => Text(
                'Pursue Badminton',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
            ),
        Text(
          'Badminton Academy Management',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          'Made with love for badminton',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
        ),
      ],
    );
  }

  void _showChangePassword(bool isDark) {
    final authState = ref.read(authProvider);
    authState.whenData((authValue) {
      if (authValue is Authenticated) {
        showDialog(
          context: context,
          builder: (context) => ChangePasswordDialog(
            userType: authValue.userType,
            userEmail: authValue.userEmail,
          ),
        );
      }
    });
  }
}
