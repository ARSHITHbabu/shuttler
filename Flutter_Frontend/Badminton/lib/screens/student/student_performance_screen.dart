import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/api_endpoints.dart';

/// Student Performance Screen - READ-ONLY view of performance records
/// Students can view their skill ratings and progress but cannot edit
class StudentPerformanceScreen extends ConsumerStatefulWidget {
  const StudentPerformanceScreen({super.key});

  @override
  ConsumerState<StudentPerformanceScreen> createState() => _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends ConsumerState<StudentPerformanceScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _performanceRecords = [];
  Map<String, dynamic> _latestPerformance = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user ID from auth provider (preferred) or storage (fallback)
      int? userId;
      
      // Try to get from auth provider first
      final authStateAsync = ref.read(authProvider);
      final authState = authStateAsync.value;
      
      if (authState is Authenticated) {
        userId = authState.userId;
      }
      
      // Fallback: try to get from storage if auth provider doesn't have it
      if (userId == null) {
        final storageService = ref.read(storageServiceProvider);
        
        // Ensure storage is initialized
        if (!storageService.isInitialized) {
          await storageService.init();
        }
        
        userId = storageService.getUserId();
      }
      
      if (userId == null) {
        throw Exception('User not logged in. Please try logging in again.');
      }

      final apiService = ref.read(apiServiceProvider);

      // Load performance records
      try {
        final response = await apiService.get(
          ApiEndpoints.performance,
          queryParameters: {'student_id': userId},
        );
        if (response.statusCode == 200) {
          // Handle different response formats
          if (response.data is List) {
            _performanceRecords = List<Map<String, dynamic>>.from(response.data);
          } else if (response.data is Map) {
            _performanceRecords = List<Map<String, dynamic>>.from(
              response.data['records'] ?? response.data['results'] ?? []
            );
          }
          
          if (_performanceRecords.isNotEmpty) {
            _latestPerformance = _performanceRecords.first;
          }
        }
      } catch (e) {
        // Endpoint may not exist yet - use empty data
        _performanceRecords = [];
        _latestPerformance = {};
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadData,
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
              child: _isLoading
                  ? const SizedBox(
                      height: 400,
                      child: Center(child: LoadingSpinner()),
                    )
                  : _error != null
                      ? _buildErrorWidget(isDark)
                      : _performanceRecords.isEmpty
                          ? _buildEmptyState(isDark)
                          : Column(
                              children: [
                                // Latest Performance Overview
                                _buildLatestPerformance(isDark),

                                const SizedBox(height: AppDimensions.spacingL),

                                // Skill Breakdown
                                _buildSkillBreakdown(isDark),

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
                                        '${_performanceRecords.length} records',
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
                            ),
            ),

            // Performance Records List
            if (!_isLoading && _error == null && _performanceRecords.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = _performanceRecords[index];
                    return _PerformanceRecordCard(
                      record: record,
                      isDark: isDark,
                    );
                  },
                  childCount: _performanceRecords.length,
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDark ? AppColors.error : AppColorsLight.error,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            _error!,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingXxl),
          Icon(
            Icons.trending_up,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'No performance records yet',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Your coach will record your performance after sessions',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLatestPerformance(bool isDark) {
    final avgScore = _calculateAverageScore(_latestPerformance);
    final date = _latestPerformance['date']?.toString() ?? '';

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
              _formatDate(date),
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

  Widget _buildSkillBreakdown(bool isDark) {
    final skills = [
      {'name': 'Serve', 'key': 'serve_rating', 'icon': Icons.sports_tennis},
      {'name': 'Smash', 'key': 'smash_rating', 'icon': Icons.bolt},
      {'name': 'Footwork', 'key': 'footwork_rating', 'icon': Icons.directions_run},
      {'name': 'Defense', 'key': 'defense_rating', 'icon': Icons.shield},
      {'name': 'Stamina', 'key': 'stamina_rating', 'icon': Icons.favorite},
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
                final rating = (_latestPerformance[skill['key']] ?? 0).toDouble();
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

  double _calculateAverageScore(Map<String, dynamic> record) {
    final skills = ['serve_rating', 'smash_rating', 'footwork_rating', 'defense_rating', 'stamina_rating'];
    double total = 0;
    int count = 0;

    for (var skill in skills) {
      final value = record[skill];
      if (value != null) {
        total += (value as num).toDouble();
        count++;
      }
    }

    return count > 0 ? total / count : 0;
  }

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
  final Map<String, dynamic> record;
  final bool isDark;

  const _PerformanceRecordCard({
    required this.record,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final date = record['date']?.toString() ?? '';
    final comments = record['comments']?.toString() ?? '';
    final avgScore = _calculateAverageScore(record);

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
                  _formatDate(date),
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
                  rating: (record['serve_rating'] ?? 0).toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Smash',
                  rating: (record['smash_rating'] ?? 0).toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Footwork',
                  rating: (record['footwork_rating'] ?? 0).toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Defense',
                  rating: (record['defense_rating'] ?? 0).toDouble(),
                  isDark: isDark,
                ),
                _MiniSkillRating(
                  label: 'Stamina',
                  rating: (record['stamina_rating'] ?? 0).toDouble(),
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

  double _calculateAverageScore(Map<String, dynamic> record) {
    final skills = ['serve_rating', 'smash_rating', 'footwork_rating', 'defense_rating', 'stamina_rating'];
    double total = 0;
    int count = 0;

    for (var skill in skills) {
      final value = record[skill];
      if (value != null) {
        total += (value as num).toDouble();
        count++;
      }
    }

    return count > 0 ? total / count : 0;
  }

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
