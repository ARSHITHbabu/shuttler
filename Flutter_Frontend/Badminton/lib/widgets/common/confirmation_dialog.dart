import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import 'neumorphic_button.dart';

/// Confirmation dialog widget
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData icon;
  final Color? confirmColor;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.icon = Icons.warning_amber_rounded,
    this.confirmColor,
    this.isDestructive = false,
  });

  /// Show delete confirmation dialog
  static Future<bool> showDelete(
    BuildContext context,
    String itemName, {
    VoidCallback? onConfirm,
  }) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: 'Delete $itemName?',
        message: 'This action cannot be undone. Are you sure you want to delete this item?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        icon: Icons.delete_outline,
        isDestructive: true,
        onConfirm: () {
          confirmed = true;
          Navigator.of(context).pop();
          onConfirm?.call();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
    return confirmed;
  }

  /// Show generic confirmation dialog
  static Future<bool> show(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Icons.help_outline,
    bool isDestructive = false,
    VoidCallback? onConfirm,
  }) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        isDestructive: isDestructive,
        onConfirm: () {
          confirmed = true;
          Navigator.of(context).pop();
          onConfirm?.call();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
    return confirmed;
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
              color: Colors.black.withOpacity(0.3),
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
              color: isDestructive ? AppColors.error : AppColors.warning,
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
                Expanded(
                  child: NeumorphicButton(
                    text: cancelText,
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    isAccent: false,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: NeumorphicButton(
                    text: confirmText,
                    onPressed: onConfirm,
                    isAccent: true,
                    color: isDestructive ? AppColors.error : null,
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
