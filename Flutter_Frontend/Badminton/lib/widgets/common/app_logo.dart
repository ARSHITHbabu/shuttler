import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final logoAsset = isDarkMode 
        ? 'assets/images/logo_dark.png' 
        : 'assets/images/logo_light.png';

    return Image.asset(
      logoAsset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        final double containerSize = height ?? width ?? 100.0;
        return Icon(
          Icons.sports_tennis,
          size: containerSize * 0.6,
          color: isDarkMode ? AppColors.accent : AppColorsLight.accent,
        );
      },
    );
  }
}
