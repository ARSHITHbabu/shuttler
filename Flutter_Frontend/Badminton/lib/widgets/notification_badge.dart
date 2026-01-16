import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

/// Notification badge widget
/// Small red dot or number badge for unread notifications
class NotificationBadge extends StatelessWidget {
  final int count;
  final double size;
  final bool showDot; // If true, shows dot instead of number when count > 0

  const NotificationBadge({
    super.key,
    required this.count,
    this.size = 8,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !showDot) {
      return const SizedBox.shrink();
    }

    if (showDot && count > 0) {
      // Simple dot badge
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      );
    }

    // Number badge
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: count > 9 ? 4 : 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count > 9 ? BorderRadius.circular(8) : null,
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Badge positioned widget - wraps a child with a badge
class BadgedWidget extends StatelessWidget {
  final Widget child;
  final int? badgeCount;
  final bool showDot;
  final Alignment badgeAlignment;

  const BadgedWidget({
    super.key,
    required this.child,
    this.badgeCount,
    this.showDot = false,
    this.badgeAlignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    if (badgeCount == null || (badgeCount! <= 0 && !showDot)) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: badgeAlignment == Alignment.topRight ? -4 : null,
          left: badgeAlignment == Alignment.topLeft ? -4 : null,
          top: badgeAlignment == Alignment.topRight || badgeAlignment == Alignment.topLeft ? -4 : null,
          bottom: badgeAlignment == Alignment.bottomRight || badgeAlignment == Alignment.bottomLeft ? -4 : null,
          child: NotificationBadge(
            count: badgeCount ?? 0,
            showDot: showDot,
          ),
        ),
      ],
    );
  }
}
