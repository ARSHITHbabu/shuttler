import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/legal_content.dart';
import '../../widgets/common/neumorphic_container.dart';

/// Terms and Conditions Screen - Displays the app's terms of service
/// This screen is shared across all portals (Owner, Coach, Student)
class TermsConditionsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const TermsConditionsScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textPrimaryColor = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondaryColor = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final accentColor = isDark ? AppColors.accent : AppColorsLight.accent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimaryColor),
          onPressed: onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Text(
          LegalContent.termsTitle,
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
              // Header Card
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        size: 32,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      LegalContent.appName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      child: Text(
                        'Last Updated: ${LegalContent.lastUpdated}',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Introduction
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Text(
                  LegalContent.termsIntro,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: textSecondaryColor,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Terms Sections
              ...LegalContent.termsSections.map((section) =>
                _buildSection(
                  title: section['title'] as String,
                  content: section['content'] as String,
                  isDark: isDark,
                  textPrimaryColor: textPrimaryColor,
                  textSecondaryColor: textSecondaryColor,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Acceptance Footer
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    Icon(
                      Icons.handshake_outlined,
                      size: 40,
                      color: accentColor,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'By using ${LegalContent.appName}, you agree to these terms',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'Thank you for choosing ${LegalContent.appName} for your badminton academy management needs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
