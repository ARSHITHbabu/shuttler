import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Reusable AppBar for More section screens with back and reload buttons
class MoreScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onReload;
  final bool isDark;
  final List<Widget>? additionalActions;
  final VoidCallback? onBack; // Custom back callback (for student screens)

  const MoreScreenAppBar({
    super.key,
    required this.title,
    this.onReload,
    required this.isDark,
    this.additionalActions,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
        ),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (onReload != null)
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? AppColors.accent : AppColorsLight.accent,
            ),
            onPressed: onReload,
          ),
        if (additionalActions != null) ...additionalActions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
