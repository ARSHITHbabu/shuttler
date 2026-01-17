import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/error/error_handler.dart';
import 'neumorphic_button.dart';

/// Error dialog widget for displaying errors in a modal
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? retryText;
  final String? dismissText;
  final IconData icon;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.retryText,
    this.dismissText,
    this.icon = Icons.error_outline,
  });

  /// Show error dialog from an error object
  static Future<void> show(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    final appError = ErrorHandler.handleError(error);
    
    String dialogTitle = title ?? 'Error';
    if (appError is NetworkError) {
      dialogTitle = title ?? 'Network Error';
    } else if (appError is ApiError) {
      dialogTitle = title ?? 'Error';
    } else if (appError is ValidationError) {
      dialogTitle = title ?? 'Validation Error';
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: dialogTitle,
        message: appError.message,
        onRetry: onRetry,
        onDismiss: onDismiss ?? () => Navigator.of(context).pop(),
        icon: _getIconForError(appError),
      ),
    );
  }

  /// Get appropriate icon for error type
  static IconData _getIconForError(AppError error) {
    if (error is NetworkError) {
      return Icons.wifi_off;
    } else if (error is ValidationError) {
      return Icons.warning_amber_rounded;
    } else if (error is ApiError) {
      return Icons.error_outline;
    }
    return Icons.error_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingS),

            // Message
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onDismiss != null)
                  Expanded(
                    child: NeumorphicButton(
                      text: dismissText ?? 'Dismiss',
                      onPressed: onDismiss,
                      isAccent: false,
                    ),
                  ),
                if (onDismiss != null && onRetry != null)
                  const SizedBox(width: AppDimensions.spacingM),
                if (onRetry != null)
                  Expanded(
                    child: NeumorphicButton(
                      text: retryText ?? 'Retry',
                      onPressed: onRetry,
                      isAccent: true,
                      icon: Icons.refresh,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Network error dialog (specialized)
class NetworkErrorDialog extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorDialog({
    super.key,
    this.onRetry,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NetworkErrorDialog(onRetry: onRetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      onDismiss: () => Navigator.of(context).pop(),
    );
  }
}

/// Validation error dialog (specialized)
class ValidationErrorDialog extends StatelessWidget {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationErrorDialog({
    super.key,
    required this.message,
    this.fieldErrors,
  });

  static Future<void> show(
    BuildContext context,
    String message, {
    Map<String, String>? fieldErrors,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => ValidationErrorDialog(
        message: message,
        fieldErrors: fieldErrors,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Validation Error',
      message: message,
      icon: Icons.warning_amber_rounded,
      onDismiss: () => Navigator.of(context).pop(),
    );
  }
}
