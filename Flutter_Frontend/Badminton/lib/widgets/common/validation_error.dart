import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// Widget to display validation error message
class ValidationError extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;

  const ValidationError({
    super.key,
    required this.message,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(
        top: AppDimensions.spacingS,
        left: AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display field-level validation errors
class FieldValidationErrors extends StatelessWidget {
  final Map<String, String> errors;
  final EdgeInsetsGeometry? padding;

  const FieldValidationErrors({
    super.key,
    required this.errors,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(top: AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 20,
                color: AppColors.error,
              ),
              SizedBox(width: AppDimensions.spacingS),
              Text(
                'Validation Errors',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          ...errors.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.spacingXs,
                left: AppDimensions.spacingM,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
