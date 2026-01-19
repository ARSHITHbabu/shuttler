import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/performance_provider.dart';
import '../../models/performance.dart';

/// Student Performance Screen - READ-ONLY view of performance records
/// Students can view their skill ratings and progress but cannot edit
class StudentPerformanceScreen extends ConsumerStatefulWidget {
  const StudentPerformanceScreen({super.key});

  @override
  ConsumerState<StudentPerformanceScreen> createState() => _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends ConsumerState<StudentPerformanceScreen> {
  // Removed manual state management - using providers instead

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get user ID from auth provider
    final authStateAsync = ref.watch(authProvider);
    
    return authStateAsync.when(
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: ListSkeleton(itemCount: 5)),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ErrorDisplay(
          message: 'Failed to load user data: ${error.toString()}',
          onRetry: () => ref.invalidate(authProvider),
        ),
      ),
      data: (authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: ErrorDisplay(
              message: 'Please log in to view performance records',
              onRetry: () => ref.invalidate(authProvider),
            ),
          );
        }

        final userId = authState.userId;
        final performanceAsync = ref.watch(performanceByStudentProvider(userId));

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(performanceByStudentProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: Text(
                    'My Performance',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                ),

                // Content
                SliverToBoxAdapter(
                  child: performanceAsync.when(
                    loading: () => const SizedBox(
                      height: 400,
                      child: ListSkeleton(itemCount: 3),
                    ),
                    error: (error, stack) => ErrorDisplay(
                      message: 'Failed to load performance records: ${error.toString()}',
                      onRetry: () => ref.invalidate(performanceByStudentProvider(userId)),
                    ),
                    data: (performanceRecords) {
                      if (performanceRecords.isEmpty) {
                        return EmptyState.noPerformance();
                      }

                      // Sort by date descending (latest first)
                      final sortedRecords = List<Performance>.from(performanceRecords)
                        ..sort((a, b) => b.date.compareTo(a.date));
                      final latestPerformance = sortedRecords.first;

                      return Column(
                        children: [
                          // Latest Performance Overview
                          _buildLatestPerformance(isDark, latestPerformance),

                          const SizedBox(height: AppDimensions.spacingL),

                          // Skill Breakdown
                          _buildSkillBreakdown(isDark, latestPerformance),

                          const SizedBox(height: AppDimensions.spacingL),

                          // Performance History Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Performance History',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${sortedRecords.length} records',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppDimensions.spacingM),
                        ],
                      );
                    },
                  ),
                ),

                // Performance Records List
                performanceAsync.when(
                  loading: () => const SliverToBoxAdapter(child: SizedBox()),
                  error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                  data: (performanceRecords) {
                    if (performanceRecords.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox());
                    }

                    // Sort by date descending (latest first)
                    final sortedRecords = List<Performance>.from(performanceRecords)
                      ..sort((a, b) => b.date.compareTo(a.date));

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final record = sortedRecords[index];
                          return _PerformanceRecordCard(
                            record: record,
                            isDark: isDark,
                          );
                        },
                        childCount: sortedRecords.length,
                      ),
                    );
                  },
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLatestPerformance(bool isDark, Performance latestPerformance) {
    final avgScore = latestPerformance.averageRating;
    final date = latestPerformance.date;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            Text(
              'Latest Assessment',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Score Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: (avgScore / 5).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(avgScore, isDark),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      avgScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      '/ 5.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingM),

            Text(
              _formatDate(date.toIso8601String()),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBreakdown(bool isDark, Performance latestPerformance) {
    final skills = [
      {'name': 'Serve', 'rating': latestPerformance.serve, 'icon': Icons.sports_tennis},
      {'name': 'Smash', 'rating': latestPerformance.smash, 'icon': Icons.bolt},
      {'name': 'Footwork', 'rating': latestPerformance.footwork, 'icon': Icons.directions_run},
      {'name': 'Defense', 'rating': latestPerformance.defense, 'icon': Icons.shield},
      {'name': 'Stamina', 'rating': latestPerformance.stamina, 'icon': Icons.favorite},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skill Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: skills.map((skill) {
                final rating = (skill['rating'] as int).toDouble();
                return _SkillBar(
                  name: skill['name'] as String,
                  rating: rating,
                  icon: skill['icon'] as IconData,
                  isDark: isDark,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Removed _calculateAverageScore - using Performance.averageRating instead

  Color _getScoreColor(double score, bool isDark) {
    if (score >= 4) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (score >= 3) {
      return isDark ? AppColors.accent : AppColorsLight.accent;
    } else if (score >= 2) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

class _SkillBar extends StatelessWidget {
  final String name;
  final double rating;
  final IconData icon;
  final bool isDark;

  const _SkillBar({
    required this.name,
    required this.rating,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColorsLight.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              boxShadow: NeumorphicStyles.getInsetShadow(),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                    Text(
                      '${rating.toStringAsFixed(1)}/5',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getSkillColor(rating, isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.background : AppColorsLight.background,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: NeumorphicStyles.getSmallInsetShadow(),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (rating / 5).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getSkillColor(rating, isDark),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSkillColor(double rating, bool isDark) {
    if (rating >= 4) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (rating >= 3) {
      return isDark ? AppColors.accent : AppColorsLight.accent;
    } else if (rating >= 2) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }
}

class _PerformanceRecordCard extends StatelessWidget {
  final Performance record;
  final bool isDark;

  const _PerformanceRecordCard({
    required this.record,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final date = record.date;
    final comments = record.comments ?? '';
    final avgScore = record.averageRating;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingS,
      ),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date.toIso8601String()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(avgScore, isDark).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    '${avgScore.toStringAsFixed(1)}/5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getScoreColor(avgScore, isDark),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Mini Skill Ratings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniSkillRating(
                  label: 'Serve',
                  rating: record.serve.toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Smash',
                  rating: record.smash.toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Footwork',
                  rating: record.footwork.toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Defense',
                  rating: record.defense.toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Stamina',
                  rating: record.stamina.toDouble(),
                  isDark: isDark,
                ),
              ],
            ),

            if (comments.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.background : AppColorsLight.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  boxShadow: NeumorphicStyles.getSmallInsetShadow(),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Text(
                        comments,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Removed _calculateAverageScore - using Performance.averageRating instead

  Color _getScoreColor(double score, bool isDark) {
    if (score >= 4) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (score >= 3) {
      return isDark ? AppColors.accent : AppColorsLight.accent;
    } else if (score >= 2) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

class _MiniSkillRating extends StatelessWidget {
  final String label;
  final double rating;
  final bool isDark;

  const _MiniSkillRating({
    required this.label,
    required this.rating,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          rating.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getColor(rating, isDark),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
        ),
      ],
    );
  }

  Color _getColor(double rating, bool isDark) {
    if (rating >= 4) {
      return isDark ? AppColors.success : AppColorsLight.success;
    } else if (rating >= 3) {
      return isDark ? AppColors.accent : AppColorsLight.accent;
    } else if (rating >= 2) {
      return Colors.orange;
    } else {
      return isDark ? AppColors.error : AppColorsLight.error;
    }
  }
}
