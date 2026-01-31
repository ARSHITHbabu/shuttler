import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';

class ContactUtils {
  static Future<void> launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  static Future<void> launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  static Future<void> launchSms(String phone) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  static void showContactOptions(BuildContext context, String phone, {String? name}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingXl,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (name != null) ...[
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            Row(
              children: [
                Expanded(
                  child: _ContactActionCard(
                    icon: Icons.phone_outlined,
                    label: 'Call',
                    color: AppColors.success,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      launchPhone(phone);
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _ContactActionCard(
                    icon: Icons.message_outlined,
                    label: 'SMS',
                    color: AppColors.accent,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      launchSms(phone);
                    },
                  ),
                ),
              ],
            ),
            // Add spacing for bottom safety area (like iPhone home indicator)
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppDimensions.spacingM),
          ],
        ),
      ),
    );
  }
}

class _ContactActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ContactActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
