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

    // Size for the circular container
    final double defaultSize = 100.0;
    final double containerSize = height ?? width ?? defaultSize;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Subtle glow matching the accent color but very faint for blending
          BoxShadow(
            color: (isDarkMode ? AppColors.accent : AppColorsLight.accent).withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: [Colors.black, Colors.transparent],
            stops: [0.85, 1.0], // Fades the outer 15% of the logo
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ClipOval(
          child: Image.asset(
            logoAsset,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.sports_tennis,
              size: containerSize != null ? containerSize * 0.6 : 40,
              color: isDarkMode ? AppColors.accent : AppColorsLight.accent,
            ),
          ),
        ),
      ),
    );
  }
}
