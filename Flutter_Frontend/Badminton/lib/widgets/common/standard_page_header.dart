import 'package:flutter/material.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/theme_colors.dart';

class StandardPageHeader extends StatelessWidget {
  final String title;
  final String? pretitle;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const StandardPageHeader({
    super.key,
    required this.title,
    this.pretitle,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = AppDimensions.getScreenPadding(context);
    final titleSize = AppDimensions.getPageTitleSize(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pretitle != null) ...[
            Text(
              pretitle!,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (showBackButton)
                      Padding(
                        padding: const EdgeInsets.only(right: AppDimensions.spacingM),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    if (leading != null)
                      Padding(
                        padding: const EdgeInsets.only(right: AppDimensions.spacingM),
                        child: leading!,
                      ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
