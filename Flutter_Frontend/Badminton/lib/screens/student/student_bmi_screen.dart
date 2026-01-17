import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';

/// Student BMI Screen - READ-ONLY view of BMI history and health status
/// Students can view their BMI records but cannot add new records
class StudentBMIScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentBMIScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentBMIScreen> createState() => _StudentBMIScreenState();
}

class _StudentBMIScreenState extends ConsumerState<StudentBMIScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bmiRecords = [];
  Map<String, dynamic> _latestBMI = {};
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

      try {
        final response = await apiService.get('/api/students/$userId/bmi');
        if (response.statusCode == 200) {
          _bmiRecords = List<Map<String, dynamic>>.from(response.data['records'] ?? []);
          if (_bmiRecords.isNotEmpty) {
            _latestBMI = _bmiRecords.first;
          }
        }
      } catch (e) {
        // Endpoint may not exist yet - use empty data
        _bmiRecords = [];
        _latestBMI = {};
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
              leading: widget.onBack != null
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                      onPressed: widget.onBack,
                    )
                  : null,
              title: Text(
                'BMI Tracker',
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
                      child: ProfileSkeleton(),
                    )
                  : _error != null
                      ? ErrorDisplay(
                          message: _error!,
                          onRetry: _loadData,
                        )
                      : _bmiRecords.isEmpty
                          ? EmptyState.noBmiRecords()
                          : Column(
                              children: [
                                // Current BMI Status
                                _buildCurrentBMI(isDark),

                                const SizedBox(height: AppDimensions.spacingL),

                                // BMI Chart/Trend
                                _buildBMITrend(isDark),

                                const SizedBox(height: AppDimensions.spacingL),

                                // Health Recommendations
                                _buildHealthRecommendations(isDark),

                                const SizedBox(height: AppDimensions.spacingL),

                                // History Header
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingL,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'BMI History',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${_bmiRecords.length} records',
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

            // BMI Records List
            if (!_isLoading && _error == null && _bmiRecords.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = _bmiRecords[index];
                    return _BMIRecordCard(
                      record: record,
                      isDark: isDark,
                      isLatest: index == 0,
                    );
                  },
                  childCount: _bmiRecords.length,
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


  Widget _buildCurrentBMI(bool isDark) {
    final bmi = (_latestBMI['bmi'] ?? 0.0).toDouble();
    final height = (_latestBMI['height'] ?? 0.0).toDouble();
    final weight = (_latestBMI['weight'] ?? 0.0).toDouble();
    final category = _getBMICategory(bmi);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            Text(
              'Current BMI Status',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // BMI Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _BMIGaugePainter(
                      bmi: bmi,
                      isDark: isDark,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingM,
                        vertical: AppDimensions.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      child: Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: category.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Height and Weight
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MeasurementItem(
                  icon: Icons.height,
                  label: 'Height',
                  value: '${height.toStringAsFixed(1)} cm',
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight,
                ),
                _MeasurementItem(
                  icon: Icons.monitor_weight,
                  label: 'Weight',
                  value: '${weight.toStringAsFixed(1)} kg',
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMITrend(bool isDark) {
    if (_bmiRecords.length < 2) {
      return const SizedBox.shrink();
    }

    // Get last 6 records for trend
    final trendRecords = _bmiRecords.take(6).toList().reversed.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BMI Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Simple trend visualization
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: trendRecords.asMap().entries.map((entry) {
                  final record = entry.value;
                  final bmi = (record['bmi'] ?? 0.0).toDouble();
                  final normalizedHeight = ((bmi - 15) / 25 * 80).clamp(10.0, 80.0);
                  final category = _getBMICategory(bmi);

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: category.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: normalizedHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.7),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingS),

            // Trend indicator
            _buildTrendIndicator(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(bool isDark) {
    if (_bmiRecords.length < 2) return const SizedBox.shrink();

    final latestBmi = (_bmiRecords[0]['bmi'] ?? 0.0).toDouble();
    final previousBmi = (_bmiRecords[1]['bmi'] ?? 0.0).toDouble();
    final diff = latestBmi - previousBmi;

    IconData icon;
    Color color;
    String text;

    if (diff.abs() < 0.1) {
      icon = Icons.trending_flat;
      color = isDark ? AppColors.accent : AppColorsLight.accent;
      text = 'Stable';
    } else if (diff > 0) {
      icon = Icons.trending_up;
      color = latestBmi > 25 ? (isDark ? AppColors.error : AppColorsLight.error) : Colors.orange;
      text = 'Increasing (+${diff.toStringAsFixed(1)})';
    } else {
      icon = Icons.trending_down;
      color = latestBmi < 18.5 ? (isDark ? AppColors.error : AppColorsLight.error) : (isDark ? AppColors.success : AppColorsLight.success);
      text = 'Decreasing (${diff.toStringAsFixed(1)})';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthRecommendations(bool isDark) {
    final bmi = (_latestBMI['bmi'] ?? 0.0).toDouble();
    final category = _getBMICategory(bmi);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  size: 20,
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  'Health Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),

            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: category.color,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      category.recommendation,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // BMI Scale Reference
            _buildBMIScale(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIScale(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BMI Categories',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Row(
          children: [
            _BMIScaleItem(label: 'Under', range: '<18.5', color: Colors.orange),
            _BMIScaleItem(label: 'Normal', range: '18.5-24.9', color: isDark ? AppColors.success : AppColorsLight.success),
            _BMIScaleItem(label: 'Over', range: '25-29.9', color: Colors.orange),
            _BMIScaleItem(label: 'Obese', range: '30+', color: isDark ? AppColors.error : AppColorsLight.error),
          ],
        ),
      ],
    );
  }

  _BMICategoryInfo _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return _BMICategoryInfo(
        label: 'Underweight',
        color: Colors.orange,
        recommendation: 'Consider increasing your calorie intake with nutrient-rich foods. Focus on protein and healthy fats.',
      );
    } else if (bmi < 25) {
      return _BMICategoryInfo(
        label: 'Normal Weight',
        color: AppColors.success,
        recommendation: 'Great job! Maintain your healthy weight with regular exercise and balanced nutrition.',
      );
    } else if (bmi < 30) {
      return _BMICategoryInfo(
        label: 'Overweight',
        color: Colors.orange,
        recommendation: 'Consider increasing physical activity and reducing calorie intake gradually.',
      );
    } else {
      return _BMICategoryInfo(
        label: 'Obese',
        color: AppColors.error,
        recommendation: 'Consult with your coach and a healthcare professional for a personalized plan.',
      );
    }
  }
}

class _BMICategoryInfo {
  final String label;
  final Color color;
  final String recommendation;

  _BMICategoryInfo({
    required this.label,
    required this.color,
    required this.recommendation,
  });
}

class _MeasurementItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _MeasurementItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BMIScaleItem extends StatelessWidget {
  final String label;
  final String range;
  final Color color;

  const _BMIScaleItem({
    required this.label,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border(
            bottom: BorderSide(color: color, width: 3),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              range,
              style: TextStyle(
                fontSize: 9,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BMIRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final bool isDark;
  final bool isLatest;

  const _BMIRecordCard({
    required this.record,
    required this.isDark,
    this.isLatest = false,
  });

  @override
  Widget build(BuildContext context) {
    final bmi = (record['bmi'] ?? 0.0).toDouble();
    final height = (record['height'] ?? 0.0).toDouble();
    final weight = (record['weight'] ?? 0.0).toDouble();
    final date = record['date']?.toString() ?? '';
    final recordedBy = record['recorded_by']?.toString() ?? '';

    final category = _getBMICategory(bmi, isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingS,
      ),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            // BMI Value Circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: isLatest
                    ? Border.all(color: category.color, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                  Text(
                    'BMI',
                    style: TextStyle(
                      fontSize: 10,
                      color: category.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        ),
                      ),
                      if (isLatest)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Latest',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.accent : AppColorsLight.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'H: ${height.toStringAsFixed(1)} cm',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        'W: ${weight.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (recordedBy.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'By: $recordedBy',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingS,
                vertical: AppDimensions.spacingXs,
              ),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                category.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: category.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  _BMICategoryData _getBMICategory(double bmi, bool isDark) {
    if (bmi < 18.5) {
      return _BMICategoryData(label: 'Underweight', color: Colors.orange);
    } else if (bmi < 25) {
      return _BMICategoryData(label: 'Normal', color: isDark ? AppColors.success : AppColorsLight.success);
    } else if (bmi < 30) {
      return _BMICategoryData(label: 'Overweight', color: Colors.orange);
    } else {
      return _BMICategoryData(label: 'Obese', color: isDark ? AppColors.error : AppColorsLight.error);
    }
  }
}

class _BMICategoryData {
  final String label;
  final Color color;

  _BMICategoryData({required this.label, required this.color});
}

class _BMIGaugePainter extends CustomPainter {
  final double bmi;
  final bool isDark;

  _BMIGaugePainter({required this.bmi, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = (isDark ? AppColors.surfaceLight : AppColorsLight.surfaceLight)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.4, // Start angle
      4.2, // Sweep angle (almost full circle)
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Calculate progress (BMI range 15-40 mapped to arc)
    final progress = ((bmi - 15) / 25).clamp(0.0, 1.0);

    // Color gradient based on BMI
    if (bmi < 18.5) {
      progressPaint.color = Colors.orange;
    } else if (bmi < 25) {
      progressPaint.color = isDark ? AppColors.success : AppColorsLight.success;
    } else if (bmi < 30) {
      progressPaint.color = Colors.orange;
    } else {
      progressPaint.color = isDark ? AppColors.error : AppColorsLight.error;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.4,
      4.2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
