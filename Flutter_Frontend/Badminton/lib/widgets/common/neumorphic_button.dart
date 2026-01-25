import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';

/// Neumorphic button with press animation and various styles
class NeumorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isAccent;
  final bool isOutlined;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;

  const NeumorphicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isAccent = false,
    this.isOutlined = false,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.textColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = AppDimensions.radiusM,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    // Calculate default padding to determine constraints
    final defaultPadding = widget.padding ??
        const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        );

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        constraints: BoxConstraints(
          minWidth: widget.width ?? 120,
          minHeight: widget.height ?? AppDimensions.buttonHeightM,
        ),
        padding: defaultPadding,
        margin: widget.margin,
        decoration: _getDecoration(isDisabled),
        child: _buildContent(isDisabled),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isDisabled) {
    if (isDisabled) {
      return BoxDecoration(
        color: AppColors.disabled,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: NeumorphicStyles.getFlatShadow(),
      );
    }

    if (widget.isOutlined) {
      return BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.color ?? AppColors.accent,
          width: 2,
        ),
        boxShadow: _isPressed
            ? NeumorphicStyles.getPressedShadow()
            : NeumorphicStyles.getElevatedShadow(),
      );
    }

    if (widget.isAccent) {
      return NeumorphicStyles.accentButtonDecoration(
        color: widget.color ?? AppColors.accent,
        borderRadius: widget.borderRadius,
        isPressed: _isPressed,
      );
    }

    return NeumorphicStyles.buttonDecoration(
      color: widget.color ?? AppColors.cardBackground,
      borderRadius: widget.borderRadius,
      isPressed: _isPressed,
    );
  }

  Widget _buildContent(bool isDisabled) {
    final textColor = isDisabled
        ? AppColors.textDisabled
        : (widget.textColor ??
            (widget.isAccent ? AppColors.textPrimary : AppColors.textPrimary));

    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: textColor,
            size: widget.fontSize + 4,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Flexible(
            child: Text(
              widget.text,
              style: TextStyle(
                color: textColor,
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        widget.text,
        style: TextStyle(
          color: textColor,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Icon button with neumorphic style
class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = AppDimensions.iconM,
    this.color,
    this.iconColor,
    this.borderRadius = AppDimensions.radiusM,
    this.padding,
    this.margin,
  });

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding ?? const EdgeInsets.all(AppDimensions.paddingM),
        margin: widget.margin,
        decoration: NeumorphicStyles.buttonDecoration(
          color: widget.color ?? AppColors.cardBackground,
          borderRadius: widget.borderRadius,
          isPressed: _isPressed,
        ),
        child: Icon(
          widget.icon,
          size: widget.size,
          color: isDisabled
              ? AppColors.textDisabled
              : (widget.iconColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}
