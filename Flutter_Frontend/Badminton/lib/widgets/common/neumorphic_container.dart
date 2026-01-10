import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';

/// Base neumorphic container widget with elevated shadow effect
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool isFlat;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = AppDimensions.radiusXl,
    this.border,
    this.onTap,
    this.isFlat = false,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: isFlat
            ? NeumorphicStyles.getFlatShadow()
            : NeumorphicStyles.getElevatedShadow(),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: widget,
      );
    }

    return widget;
  }
}

/// Inset neumorphic container (sunken effect) - for input fields
class NeumorphicInsetContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;
  final Border? border;

  const NeumorphicInsetContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = AppDimensions.radiusM,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: NeumorphicStyles.getInsetShadow(),
      ),
      child: child,
    );
  }
}
