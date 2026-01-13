import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// Custom app bar with back button, title, and actions
/// Provides consistent styling across all screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<AppBarAction>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: elevation,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      actions: actions?.map((action) {
        if (action.isSearch) {
          return IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.accent,
            ),
            onPressed: action.onPressed,
            tooltip: action.tooltip ?? 'Search',
          );
        } else if (action.isFilter) {
          return IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: AppColors.accent,
            ),
            onPressed: action.onPressed,
            tooltip: action.tooltip ?? 'Filter',
          );
        } else if (action.isAdd) {
          return IconButton(
            icon: const Icon(
              Icons.add,
              color: AppColors.accent,
            ),
            onPressed: action.onPressed,
            tooltip: action.tooltip ?? 'Add',
          );
        } else {
          return IconButton(
            icon: Icon(
              action.icon,
              color: action.color ?? AppColors.textPrimary,
            ),
            onPressed: action.onPressed,
            tooltip: action.tooltip,
          );
        }
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);
}

/// App bar action data
class AppBarAction {
  final IconData? icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final bool isSearch;
  final bool isFilter;
  final bool isAdd;

  const AppBarAction({
    this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.isSearch = false,
    this.isFilter = false,
    this.isAdd = false,
  }) : assert(
          icon != null || isSearch || isFilter || isAdd,
          'Either icon or one of isSearch/isFilter/isAdd must be provided',
        );

  /// Factory constructor for search action
  factory AppBarAction.search({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      isSearch: true,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  /// Factory constructor for filter action
  factory AppBarAction.filter({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      isFilter: true,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  /// Factory constructor for add action
  factory AppBarAction.add({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AppBarAction(
      isAdd: true,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  /// Factory constructor for custom icon action
  factory AppBarAction.custom({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color,
  }) {
    return AppBarAction(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
    );
  }
}
