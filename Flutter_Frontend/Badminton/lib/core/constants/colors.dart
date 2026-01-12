import 'package:flutter/material.dart';

/// App color palette matching the React UI neumorphic dark theme
class AppColors {
  // Background colors
  static const Color background = Color(0xFF1a1a1a); // #1a1a1a
  static const Color cardBackground = Color(0xFF242424); // #242424
  static const Color surfaceLight = Color(0xFF2a2a2a); // #2a2a2a

  // Text colors
  static const Color textPrimary = Color(0xFFe8e8e8); // #e8e8e8
  static const Color textSecondary = Color(0xFF888888); // #888888
  static const Color textTertiary = Color(0xFF707070); // #707070 (inactive text)
  static const Color textHint = Color(0xFF666666); // #666666
  
  // Icon colors
  static const Color iconPrimary = Color(0xFFa0a0a0); // #a0a0a0
  static const Color iconActive = Color(0xFFc0c0c0); // #c0c0c0 (active icon)

  // Accent colors
  static const Color accent = Color(0xFF4a9eff); // Blue accent
  static const Color accentDark = Color(0xFF3a7ecf); // Darker blue

  // Status colors
  static const Color success = Color(0xFF4caf50); // Green
  static const Color error = Color(0xFFf44336); // Red
  static const Color warning = Color(0xFFff9800); // Orange
  static const Color info = Color(0xFF2196f3); // Blue

  // Event colors (for calendar)
  static const Color eventHoliday = Color(0xFFf44336); // Red
  static const Color eventTournament = Color(0xFF4caf50); // Green
  static const Color eventInHouse = Color(0xFF2196f3); // Blue

  // Shadow colors
  static const Color shadowDark = Colors.black;
  static const Color shadowLight = Colors.white;

  // Overlay colors
  static const Color overlay = Color(0x80000000); // Semi-transparent black
  static const Color overlayLight = Color(0x40000000); // More transparent

  // Border colors
  static const Color border = Color(0xFF333333);
  static const Color borderLight = Color(0xFF444444);

  // Disabled state
  static const Color disabled = Color(0xFF555555);
  static const Color textDisabled = Color(0xFF666666);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4a9eff), Color(0xFF3a7ecf)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1a1a1a), Color(0xFF242424)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Background gradient matching React: from-[#1a1a1a] to-[#0f0f0f]
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1a1a1a), Color(0xFF0f0f0f)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
