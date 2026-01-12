import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Neumorphic shadow and style definitions matching React UI
class NeumorphicStyles {
  /// Elevated shadow effect (outset) - used for buttons and cards
  /// Creates a raised, 3D effect matching React: 8px 8px 16px rgba(0,0,0,0.5), -8px -8px 16px rgba(40,40,40,0.1)
  static List<BoxShadow> getElevatedShadow({
    double blurRadius = 16.0,
    double offset = 8.0,
  }) {
    return [
      // Dark shadow (bottom-right) - 8px 8px 16px rgba(0,0,0,0.5)
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.5),
        offset: Offset(offset, offset),
        blurRadius: blurRadius,
      ),
      // Light shadow (top-left) - -8px -8px 16px rgba(40,40,40,0.1)
      BoxShadow(
        color: const Color(0xFF282828).withOpacity(0.1), // rgba(40,40,40,0.1)
        offset: Offset(-offset, -offset),
        blurRadius: blurRadius,
      ),
    ];
  }

  /// Inset shadow effect - used for text fields and pressed buttons
  /// Creates a sunken, depressed effect matching React: inset 4px 4px 8px rgba(0,0,0,0.5)
  static List<BoxShadow> getInsetShadow({
    double blurRadius = 8.0,
    double offset = 4.0,
    double spreadRadius = -2.0,
  }) {
    return [
      // Inset shadow - inset 4px 4px 8px rgba(0,0,0,0.5)
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.5),
        offset: Offset(offset, offset),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
      // Light inset highlight - inset -4px -4px 8px rgba(40,40,40,0.1)
      BoxShadow(
        color: const Color(0xFF282828).withOpacity(0.1),
        offset: Offset(-offset, -offset),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
  
  /// Small inset shadow for input fields - inset 2px 2px 4px rgba(0,0,0,0.5)
  static List<BoxShadow> getSmallInsetShadow() {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.5),
        offset: const Offset(2, 2),
        blurRadius: 4.0,
        spreadRadius: -1.0,
      ),
    ];
  }

  /// Flat shadow - minimal elevation
  static List<BoxShadow> getFlatShadow() {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.2),
        offset: const Offset(2, 2),
        blurRadius: 4,
      ),
    ];
  }

  /// Pressed shadow - for active/pressed state matching React: inset 4px 4px 8px rgba(0,0,0,0.5), inset -4px -4px 8px rgba(40,40,40,0.1)
  static List<BoxShadow> getPressedShadow() {
    return [
      // Inset dark shadow
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.5),
        offset: const Offset(4, 4),
        blurRadius: 8.0,
        spreadRadius: -2.0,
      ),
      // Inset light highlight
      BoxShadow(
        color: const Color(0xFF282828).withOpacity(0.1),
        offset: const Offset(-4, -4),
        blurRadius: 8.0,
        spreadRadius: -2.0,
      ),
    ];
  }

  /// Elevated shadow with accent color glow
  static List<BoxShadow> getAccentShadow({
    Color? accentColor,
    double blurRadius = 12.0,
    double offset = 6.0,
  }) {
    final color = accentColor ?? AppColors.accent;
    return [
      // Accent glow
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: blurRadius * 1.5,
        spreadRadius: 2,
      ),
      // Dark shadow
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.4),
        offset: Offset(offset, offset),
        blurRadius: blurRadius,
      ),
    ];
  }

  /// Card decoration with elevated shadow
  static BoxDecoration cardDecoration({
    Color? color,
    double borderRadius = 20.0,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: getElevatedShadow(),
    );
  }

  /// Input field decoration with inset shadow
  static BoxDecoration inputDecoration({
    Color? color,
    double borderRadius = 15.0,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: getInsetShadow(),
    );
  }

  /// Button decoration with elevated shadow
  static BoxDecoration buttonDecoration({
    Color? color,
    double borderRadius = 15.0,
    Border? border,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: isPressed ? getPressedShadow() : getElevatedShadow(),
    );
  }

  /// Accent button decoration with glow effect
  static BoxDecoration accentButtonDecoration({
    Color? color,
    double borderRadius = 15.0,
    bool isPressed = false,
  }) {
    final buttonColor = color ?? AppColors.accent;
    return BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isPressed ? getPressedShadow() : getAccentShadow(accentColor: buttonColor),
    );
  }
}
