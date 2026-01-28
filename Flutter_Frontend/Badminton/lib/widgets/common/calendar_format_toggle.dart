import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// Custom Calendar Format Toggle Widget
/// Provides a consistent UI for switching between Week, 2 Weeks, and Month views
/// across all calendar screens (coach, student, owner portals)
class CalendarFormatToggle extends StatelessWidget {
  final CalendarFormat currentFormat;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final bool isDark;

  const CalendarFormatToggle({
    super.key,
    required this.currentFormat,
    required this.onFormatChanged,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;
    final selectedColor = isDark ? AppColors.accent : AppColorsLight.accent;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: 'Week',
            isSelected: currentFormat == CalendarFormat.week,
            selectedColor: selectedColor,
            textColor: currentFormat == CalendarFormat.week ? Colors.white : textSecondary,
            onTap: () => onFormatChanged(CalendarFormat.week),
          ),
          const SizedBox(width: 4),
          _ToggleButton(
            label: '2 Weeks',
            isSelected: currentFormat == CalendarFormat.twoWeeks,
            selectedColor: selectedColor,
            textColor: currentFormat == CalendarFormat.twoWeeks ? Colors.white : textSecondary,
            onTap: () => onFormatChanged(CalendarFormat.twoWeeks),
          ),
          const SizedBox(width: 4),
          _ToggleButton(
            label: 'Month',
            isSelected: currentFormat == CalendarFormat.month,
            selectedColor: selectedColor,
            textColor: currentFormat == CalendarFormat.month ? Colors.white : textSecondary,
            onTap: () => onFormatChanged(CalendarFormat.month),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
