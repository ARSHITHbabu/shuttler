import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/legal_content.dart';
import '../../widgets/common/neumorphic_container.dart';

/// Privacy Policy Screen - Displays the app's privacy policy
/// This screen is shared across all portals (Owner, Coach, Student)
class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const PrivacyPolicyScreen({super.key, this.onBack});

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: textPrimaryColor, size: 20),
          ),
          onPressed: onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Text(
          LegalContent.privacyPolicyTitle,
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 600;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacingM),
                  // Header Card - Premium Look
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingL : AppDimensions.paddingXl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                          ? [AppColors.surface, AppColors.background] 
                          : [AppColorsLight.cardBackground, AppColorsLight.background],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.privacy_tip_outlined,
                            size: isSmallScreen ? 32 : 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
                        Text(
                          LegalContent.appName,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL,
                            vertical: AppDimensions.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.update, size: 14, color: accentColor),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Last Updated: ${LegalContent.lastUpdated}',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // Introduction
                  _buildContentCard(
                    child: Text(
                      LegalContent.privacyPolicyIntro,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 15,
                        height: 1.8,
                        color: textSecondaryColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Policy Sections
                  ...LegalContent.privacyPolicySections.map((section) =>
                    _buildSection(
                      title: section['title'] as String,
                      content: section['content'] as String,
                      isDark: isDark,
                      textPrimaryColor: textPrimaryColor,
                      textSecondaryColor: textSecondaryColor,
                      accentColor: accentColor,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: textSecondaryColor.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.security,
                            size: 24,
                            color: textSecondaryColor.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        Text(
                          'Your privacy is our top priority',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w500,
                            color: textSecondaryColor.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentCard({required Widget child, required bool isDark, bool isSmallScreen = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color accentColor,
    bool isSmallScreen = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _buildContentCard(
            isDark: isDark,
            isSmallScreen: isSmallScreen,
            child: Text(
              content,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                height: 1.7,
                color: textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
