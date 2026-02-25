import 'package:flutter/material.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../core/utils/theme_colors.dart';

class StandardBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<StandardBottomNavItem> items;
  final Function(int) onTap;

  const StandardBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = context.surfaceLightColor;
    final shadowColor = isDark ? const Color(0xFF000000) : const Color(0xFFAAAAAA);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: surfaceColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingS,
            vertical: isSmallScreen ? 8 : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(context, index, isSmallScreen),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, bool isSmallScreen) {
    final item = items[index];
    final isActive = currentIndex == index;
    final activeColor = context.iconActiveColor;
    final inactiveColor = context.textTertiaryColor;
    final cardColor = context.cardBackgroundColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: isActive ? cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: isActive ? NeumorphicStyles.getPressedShadow() : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 20,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StandardBottomNavItem {
  final IconData icon;
  final String label;

  StandardBottomNavItem({required this.icon, required this.label});
}
