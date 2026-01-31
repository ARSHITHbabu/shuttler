import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/settings/shuttlecock_theme_toggle.dart';
import '../common/privacy_policy_screen.dart';
import '../common/terms_conditions_screen.dart';
import '../common/help_support_screen.dart';
import '../../widgets/forms/change_password_dialog.dart';
import '../../widgets/common/more_screen_app_bar.dart';
import 'student_profile_screen.dart';

/// Student Settings Screen - App preferences and account settings
/// Students can toggle theme, manage notifications, and logout
class StudentSettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentSettingsScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentSettingsScreen> createState() =>
      _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends ConsumerState<StudentSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _attendanceReminders = true;
  bool _feeReminders = true;

  static const String _settingsKey = 'student_settings';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from local storage
    try {
      final storageService = ref.read(storageServiceProvider);
      final settingsJson = await storageService.getString(_settingsKey);
      if (settingsJson != null && mounted) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        setState(() {
          _pushNotifications = settings['push_notifications'] ?? true;
          _emailNotifications = settings['email_notifications'] ?? true;
          _attendanceReminders = settings['attendance_reminders'] ?? true;
          _feeReminders = settings['fee_reminders'] ?? true;
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
        'attendance_reminders': _attendanceReminders,
        'fee_reminders': _feeReminders,
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

    void handleReload() {
      // Settings screen doesn't need to reload providers, but we can refresh the UI
      setState(() {});
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: MoreScreenAppBar(
        title: 'Settings',
        onReload: handleReload,
        isDark: isDark,
        onBack: widget.onBack,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          handleReload();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [

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
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColorsLight.textPrimary,
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
                        onTap: () => _navigateToProfile(),
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        title: 'Change Password',
                        icon: Icons.lock_outline,
                        isDark: isDark,
                        onTap: () => _showChangePassword(isDark),
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        title: 'Logout',
                        icon: Icons.logout,
                        isDark: isDark,
                        isDestructive: true,
                        onTap: () => _showLogoutConfirmation(isDark),
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

                  // Reminders Section
                  _buildSection(
                    title: 'Reminders',
                    icon: Icons.alarm_outlined,
                    isDark: isDark,
                    children: [
                      _buildSwitchTile(
                        title: 'Attendance Reminders',
                        subtitle: 'Get reminded about upcoming sessions',
                        value: _attendanceReminders,
                        onChanged: (value) {
                          setState(() => _attendanceReminders = value);
                          _saveSettings();
                        },
                        isDark: isDark,
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'Fee Reminders',
                        subtitle: 'Get reminded about pending fees',
                        value: _feeReminders,
                        onChanged: (value) {
                          setState(() => _feeReminders = value);
                          _saveSettings();
                        },
                        isDark: isDark,
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
                              builder: (context) =>
                                  const TermsConditionsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        title: 'Contact Support',
                        icon: Icons.support_agent_outlined,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HelpSupportScreen(userRole: 'student'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // App Branding
                  _buildAppBranding(isDark),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          ],
        ),
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
                  color: (isDark ? AppColors.accent : AppColorsLight.accent)
                      .withValues(alpha: 0.1),
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
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColorsLight.textPrimary,
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
            child: Column(children: children),
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
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColorsLight.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor:
                (isDark ? AppColors.accent : AppColorsLight.accent).withValues(
                  alpha: 0.5,
                ),
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
              color: isDark
                  ? AppColors.textPrimary
                  : AppColorsLight.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColorsLight.textSecondary,
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
                  : (isDark
                        ? AppColors.iconPrimary
                        : AppColorsLight.iconPrimary),
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
                      : (isDark
                            ? AppColors.textPrimary
                            : AppColorsLight.textPrimary),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark
                  ? AppColors.textTertiary
                  : AppColorsLight.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBranding(bool isDark) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isDark ? AppColors.accent : AppColorsLight.accent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: const Icon(Icons.sports_tennis, size: 32, color: Colors.white),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Text(
          'Shuttler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        Text(
          'Badminton Academy Management',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondary
                : AppColorsLight.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          'Made with love for badminton',
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.textTertiary
                : AppColorsLight.textTertiary,
          ),
        ),
      ],
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            StudentProfileScreen(onBack: () => Navigator.of(context).pop()),
      ),
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

  void _showLogoutConfirmation(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.cardBackground
            : AppColorsLight.cardBackground,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondary
                : AppColorsLight.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColorsLight.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              navigator.pop();
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                router.go('/');
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: isDark ? AppColors.error : AppColorsLight.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
