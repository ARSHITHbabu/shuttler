import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';

/// Profile Screen - Edit owner profile details
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textPrimaryColor = theme.colorScheme.onSurface;
    final textSecondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final textHintColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    final iconPrimaryColor = isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary;
    final cardBackground = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;

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
          'Profile',
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
              // Profile Avatar Section
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: cardBackground,
                        shape: BoxShape.circle,
                        boxShadow: NeumorphicStyles.getInsetShadow(),
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 32,
                            color: iconPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Admin Owner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Owner',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Full Name Field
              NeumorphicInsetContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: TextField(
                  style: TextStyle(color: textPrimaryColor),
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: textHintColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Email Field
              NeumorphicInsetContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: TextField(
                  style: TextStyle(color: textPrimaryColor),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: textHintColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Phone Field
              NeumorphicInsetContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: TextField(
                  style: TextStyle(color: textPrimaryColor),
                  decoration: InputDecoration(
                    hintText: 'Phone',
                    hintStyle: TextStyle(color: textHintColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Save Button
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                onTap: () {
                  // Save changes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile saved')),
                  );
                },
                child: Center(
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      color: textPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
