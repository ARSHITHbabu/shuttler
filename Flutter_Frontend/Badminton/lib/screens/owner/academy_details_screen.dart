import 'package:flutter/material.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';

/// Academy Details Screen - Edit academy information
class AcademyDetailsScreen extends StatelessWidget {
  const AcademyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textPrimaryColor = theme.colorScheme.onSurface;
    final textHintColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

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
          'Academy Details',
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
              // Academy Name Field
              NeumorphicInsetContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: TextField(
                  style: TextStyle(color: textPrimaryColor),
                  decoration: InputDecoration(
                    hintText: 'Academy Name',
                    hintStyle: TextStyle(color: textHintColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Address Field
              NeumorphicInsetContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: TextField(
                  style: TextStyle(color: textPrimaryColor),
                  decoration: InputDecoration(
                    hintText: 'Address',
                    hintStyle: TextStyle(color: textHintColor),
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Contact Number Field
              NeumorphicInsetContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: TextField(
                  style: TextStyle(color: textPrimaryColor),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Contact Number',
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Academy Email',
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
                    const SnackBar(content: Text('Academy details saved')),
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
