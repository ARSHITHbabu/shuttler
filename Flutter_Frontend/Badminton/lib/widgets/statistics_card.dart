import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/dimensions.dart';
import '../core/theme/neumorphic_styles.dart';
import 'common/neumorphic_container.dart';

/// Statistics card widget for dashboard
/// Displays icon, label, value with optional trend indicator
class StatisticsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final TrendIndicator? trend;

  const StatisticsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  boxShadow: NeumorphicStyles.getInsetShadow(),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.iconPrimary,
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: AppDimensions.spacingS),
                _TrendIndicator(trend: trend!),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Trend indicator showing up/down arrow with percentage
class _TrendIndicator extends StatelessWidget {
  final TrendIndicator trend;

  const _TrendIndicator({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isPositive = trend.value >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          '${trend.value.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Trend indicator data
class TrendIndicator {
  final double value; // Percentage change (positive = up, negative = down)
  final String? period; // Optional: "vs last week", "vs last month", etc.

  const TrendIndicator({
    required this.value,
    this.period,
  });
}
