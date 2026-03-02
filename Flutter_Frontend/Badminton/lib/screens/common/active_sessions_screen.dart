import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../core/services/auth_service.dart';

class ActiveSessionsScreen extends ConsumerStatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  ConsumerState<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends ConsumerState<ActiveSessionsScreen> {
  bool _isLoading = true;
  List<dynamic> _sessions = [];
  
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() { _isLoading = true; });
    try {
      final authService = ref.read(authServiceProvider);
      final sessions = await authService.getActiveSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sessions: $e')),
        );
      }
    }
  }

  Future<void> _revokeSession(int sessionId) async {
    final confirm = await ConfirmationDialog.show(
      context,
      'Revoke Session',
      'Are you sure you want to log out of this device?',
      confirmText: 'Log Out',
      cancelText: 'Cancel',
      icon: Icons.logout,
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.revokeSession(sessionId);
      if (mounted) {
        SuccessSnackbar.show(context, 'Session revoked successfully');
        _loadSessions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke session: $e')),
        );
      }
    }
  }

  Future<void> _logoutAll() async {
    final confirm = await ConfirmationDialog.show(
      context,
      'Log Out All Devices',
      'Are you sure you want to log out of ALL devices, including this one?',
      confirmText: 'Log Out All',
      cancelText: 'Cancel',
      icon: Icons.power_settings_new,
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.logoutAll();
      if (mounted) {
        // Auth provider should automatically trigger auth state change and redirect to login
        ref.read(authProvider.notifier).logout();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out all devices: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Active Sessions',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.power_settings_new,
              color: isDark ? AppColors.error : AppColorsLight.error,
            ),
            tooltip: 'Log out all devices',
            onPressed: _logoutAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Text(
                    'No active sessions found.',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      final isCurrent = session['is_current'] == true;
                      final ipAddress = session['ip_address'] ?? 'Unknown location';
                      final userAgent = session['user_agent'] ?? 'Unknown device';
                      final createdAt = session['created_at'] != null 
                          ? DateFormat('MMM d, yyyy • h:mm a').format(DateTime.parse(session['created_at']).toLocal())
                          : 'Unknown time';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                        child: NeumorphicContainer(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isCurrent 
                                      ? (isDark ? AppColors.success : AppColorsLight.success)
                                      : (isDark ? AppColors.accent : AppColorsLight.accent)).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                ),
                                child: Icon(
                                  isCurrent ? Icons.check_circle_outline : Icons.devices,
                                  color: isCurrent 
                                      ? (isDark ? AppColors.success : AppColorsLight.success)
                                      : (isDark ? AppColors.accent : AppColorsLight.accent),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            ipAddress,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isCurrent)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (isDark ? AppColors.success : AppColorsLight.success).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Current',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDark ? AppColors.success : AppColorsLight.success,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userAgent,
                                      style: TextStyle(
                                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Started: $createdAt',
                                      style: TextStyle(
                                        color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isCurrent)
                                IconButton(
                                  icon: Icon(
                                    Icons.logout,
                                    color: isDark ? AppColors.error : AppColorsLight.error,
                                  ),
                                  tooltip: 'Revoke session',
                                  onPressed: () => _revokeSession(session['id']),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
