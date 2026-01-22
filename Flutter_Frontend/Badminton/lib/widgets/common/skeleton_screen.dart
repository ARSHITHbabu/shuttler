import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import 'shimmer_loading.dart';

/// Skeleton screen for dashboard loading
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics cards skeleton
          Row(
            children: [
              Expanded(child: _StatCardSkeleton()),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(child: _StatCardSkeleton()),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(child: _StatCardSkeleton()),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(child: _StatCardSkeleton()),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Section title skeleton
          _SectionTitleSkeleton(),
          const SizedBox(height: AppDimensions.spacingM),
          
          // List skeleton
          const ShimmerList(itemCount: 3),
        ],
      ),
    );
  }
}

/// Skeleton for statistics card
class _StatCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBackground,
      highlightColor: AppColors.surfaceLight,
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Container(
              width: 80,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for section title
class _SectionTitleSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBackground,
      highlightColor: AppColors.surfaceLight,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: 150,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Skeleton screen for list loading
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool hasLeading;
  final bool hasSubtitle;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.hasLeading = true,
    this.hasSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerListTile(
          hasLeading: hasLeading,
          hasSubtitle: hasSubtitle,
        );
      },
    );
  }
}

/// Skeleton screen for card grid loading
class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const GridSkeleton({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: AppDimensions.spacingM,
        mainAxisSpacing: AppDimensions.spacingM,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerCard();
      },
    );
  }
}

/// Skeleton screen for profile loading
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // Profile picture skeleton
          Shimmer.fromColors(
            baseColor: AppColors.cardBackground,
            highlightColor: AppColors.surfaceLight,
            period: const Duration(milliseconds: 1200),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Name skeleton
          Shimmer.fromColors(
            baseColor: AppColors.cardBackground,
            highlightColor: AppColors.surfaceLight,
            period: const Duration(milliseconds: 1200),
            child: Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          
          // Email skeleton
          Shimmer.fromColors(
            baseColor: AppColors.cardBackground,
            highlightColor: AppColors.surfaceLight,
            period: const Duration(milliseconds: 1200),
            child: Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          
          // Form fields skeleton
          ...List.generate(5, (index) => _FormFieldSkeleton()),
        ],
      ),
    );
  }
}

/// Skeleton for form field
class _FormFieldSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.cardBackground,
            highlightColor: AppColors.surfaceLight,
            period: const Duration(milliseconds: 1200),
            child: Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Shimmer.fromColors(
            baseColor: AppColors.cardBackground,
            highlightColor: AppColors.surfaceLight,
            period: const Duration(milliseconds: 1200),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
