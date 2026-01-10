import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Loading spinner widget with optional overlay
class LoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool showOverlay;

  const LoadingSpinner({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
    this.showOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.accent,
        ),
      ),
    );

    if (showOverlay) {
      return Container(
        color: AppColors.overlay,
        child: Center(child: spinner),
      );
    }

    return Center(child: spinner);
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.overlay,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingSpinner(size: 50),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small inline loading indicator
class InlineLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const InlineLoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.accent,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 8),
          Text(
            message!,
            style: TextStyle(
              color: color ?? AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
