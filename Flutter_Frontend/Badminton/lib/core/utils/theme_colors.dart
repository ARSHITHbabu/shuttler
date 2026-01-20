import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Extension on BuildContext to provide theme-aware colors
extension ThemeColors on BuildContext {
  /// Check if current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get background color based on theme
  Color get backgroundColor => isDarkMode ? AppColors.background : AppColorsLight.background;

  /// Get card background color based on theme
  Color get cardBackgroundColor => isDarkMode ? AppColors.cardBackground : AppColorsLight.cardBackground;

  /// Get surface light color based on theme
  Color get surfaceLightColor => isDarkMode ? AppColors.surfaceLight : AppColorsLight.surfaceLight;

  /// Get text primary color based on theme
  Color get textPrimaryColor => isDarkMode ? AppColors.textPrimary : AppColorsLight.textPrimary;

  /// Get text secondary color based on theme
  Color get textSecondaryColor => isDarkMode ? AppColors.textSecondary : AppColorsLight.textSecondary;

  /// Get text tertiary color based on theme
  Color get textTertiaryColor => isDarkMode ? AppColors.textTertiary : AppColorsLight.textTertiary;

  /// Get text hint color based on theme
  Color get textHintColor => isDarkMode ? AppColors.textHint : AppColorsLight.textHint;

  /// Get icon primary color based on theme
  Color get iconPrimaryColor => isDarkMode ? AppColors.iconPrimary : AppColorsLight.iconPrimary;

  /// Get icon active color based on theme
  Color get iconActiveColor => isDarkMode ? AppColors.iconActive : AppColorsLight.iconActive;

  /// Get accent color (same for both themes)
  Color get accentColor => AppColors.accent;

  /// Get accent dark color (same for both themes)
  Color get accentDarkColor => AppColors.accentDark;

  /// Get success color (same for both themes)
  Color get successColor => AppColors.success;

  /// Get error color (same for both themes)
  Color get errorColor => AppColors.error;

  /// Get warning color (same for both themes)
  Color get warningColor => AppColors.warning;

  /// Get info color (same for both themes)
  Color get infoColor => AppColors.info;

  /// Get border color based on theme
  Color get borderColor => isDarkMode ? AppColors.border : AppColorsLight.border;

  /// Get border light color based on theme
  Color get borderLightColor => isDarkMode ? AppColors.borderLight : AppColorsLight.borderLight;

  /// Get disabled color based on theme
  Color get disabledColor => isDarkMode ? AppColors.disabled : AppColorsLight.disabled;

  /// Get text disabled color based on theme
  Color get textDisabledColor => isDarkMode ? AppColors.textDisabled : AppColorsLight.textDisabled;

  /// Get overlay color based on theme
  Color get overlayColor => isDarkMode ? AppColors.overlay : AppColorsLight.overlay;

  /// Get overlay light color based on theme
  Color get overlayLightColor => isDarkMode ? AppColors.overlayLight : AppColorsLight.overlayLight;

  /// Get background gradient based on theme
  LinearGradient get backgroundGradient => isDarkMode 
      ? AppColors.backgroundGradient 
      : AppColorsLight.backgroundGradient;

  /// Get primary gradient (same for both themes)
  LinearGradient get primaryGradient => AppColors.primaryGradient;
}
