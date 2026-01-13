import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// Cached profile image widget
/// Circular cached network image with placeholder and error handling
class CachedProfileImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final String? placeholderText;
  final Color? backgroundColor;

  const CachedProfileImage({
    super.key,
    required this.imageUrl,
    this.size = AppDimensions.avatarM,
    this.placeholderText,
    this.backgroundColor,
  });

  String _getInitials(String? text) {
    if (text == null || text.isEmpty) return '?';
    final parts = text.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.accent.withValues(alpha: 0.2),
        border: Border.all(
          color: AppColors.accent,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          errorWidget: (context, url, error) => _ErrorPlaceholder(
            size: size,
            initials: _getInitials(placeholderText),
          ),
        ),
      ),
    );
  }
}

/// Error placeholder widget
class _ErrorPlaceholder extends StatelessWidget {
  final double size;
  final String initials;

  const _ErrorPlaceholder({
    required this.size,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: size * 0.3,
              color: AppColors.error,
            ),
            if (initials != '?') ...[
              const SizedBox(height: 4),
              Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
