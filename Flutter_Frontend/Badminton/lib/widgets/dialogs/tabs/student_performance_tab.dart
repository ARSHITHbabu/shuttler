import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/success_snackbar.dart';
import '../../../widgets/common/confirmation_dialog.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/performance_provider.dart';
import '../../../models/performance.dart';
import '../../../models/student.dart';
import 'package:intl/intl.dart';

/// Performance Tab - Shows performance history, charts, and allows adding/editing records
class StudentPerformanceTab extends ConsumerStatefulWidget {
  final Student student;

  const StudentPerformanceTab({
    super.key,
    required this.student,
  });

  @override
  ConsumerState<StudentPerformanceTab> createState() => _StudentPerformanceTabState();
}

class _StudentPerformanceTabState extends ConsumerState<StudentPerformanceTab> {
  bool _showAddForm = false;
  DateTime _selectedDate = DateTime.now();
  final _commentController = TextEditingController();
  final Map<String, int> _ratings = {
    'serve': 0,
    'smash': 0,
    'footwork': 0,
    'defense': 0,
    'stamina': 0,
  };
  bool _isLoading = false;
  int? _editingPerformanceId;

  final List<Map<String, dynamic>> _skills = [
    {'key': 'serve', 'label': 'Serve', 'icon': Icons.sports_tennis},
    {'key': 'smash', 'label': 'Smash', 'icon': Icons.flash_on},
    {'key': 'footwork', 'label': 'Footwork', 'icon': Icons.directions_run},
    {'key': 'defense', 'label': 'Defense', 'icon': Icons.shield},
    {'key': 'stamina', 'label': 'Stamina', 'icon': Icons.fitness_center},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      return _buildAddForm();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performance Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showAddForm = true),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Performance History
          _buildPerformanceHistory(),
        ],
      ),
    );
  }

  Widget _buildPerformanceHistory() {
    final performanceAsync = ref.watch(performanceByStudentProvider(widget.student.id));

    return performanceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Failed to load performance: ${error.toString()}',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(
                  Icons.trending_up_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                const Text(
                  'No performance records yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort by date descending
        final sortedRecords = List<Performance>.from(records)
          ..sort((a, b) => b.date.compareTo(a.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Chart (if 2+ records)
            if (sortedRecords.length >= 2) ...[
              _buildProgressChart(sortedRecords),
              const SizedBox(height: AppDimensions.spacingL),
            ],
            
            // Records List
            ...sortedRecords.map((performance) => _buildPerformanceCard(performance)),
          ],
        );
      },
    );
  }

  Widget _buildProgressChart(List<Performance> records) {
    // Sort by date ascending for chart
    final sortedHistory = List<Performance>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.averageRating);
    }).toList();

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Average Performance Over Time',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= sortedHistory.length) {
                          return const Text('');
                        }
                        final date = sortedHistory[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM dd').format(date),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (sortedHistory.length - 1).toDouble(),
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.accent,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accent.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(Performance performance) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM, yyyy').format(performance.date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      'Avg: ${performance.averageRating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    color: AppColors.cardBackground,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: AppColors.textPrimary),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            _editPerformance(performance);
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            _deletePerformance(performance);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildSkillRow('Serve', performance.serve),
          _buildSkillRow('Smash', performance.smash),
          _buildSkillRow('Footwork', performance.footwork),
          _buildSkillRow('Defense', performance.defense),
          _buildSkillRow('Stamina', performance.stamina),
          if (performance.comments != null && performance.comments!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comment',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        performance.comments!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillRow(String skill, int rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            skill,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 16,
                color: index < rating
                    ? AppColors.warning
                    : AppColors.textSecondary,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _editingPerformanceId != null ? 'Edit Performance' : 'Add Performance',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () {
                  setState(() {
                    _showAddForm = false;
                    _editingPerformanceId = null;
                    _ratings.updateAll((key, value) => 0);
                    _commentController.clear();
                    _selectedDate = DateTime.now();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Date Picker
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                  const SizedBox(width: AppDimensions.spacingM),
                  Text(
                    DateFormat('dd MMM, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Skill Ratings
          const Text(
            'Skill Ratings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          ..._skills.map((skill) => _buildRatingField(skill)),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Comments
          CustomTextField(
            controller: _commentController,
            label: 'Comments (Optional)',
            hint: 'Add any additional notes...',
            maxLines: 3,
          ),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _savePerformance,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _editingPerformanceId != null ? 'Update Performance' : 'Save Performance',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingField(Map<String, dynamic> skill) {
    final key = skill['key'] as String;
    final label = skill['label'] as String;
    final icon = skill['icon'] as IconData;
    final rating = _ratings[key] ?? 0;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final starRating = index + 1;
              return InkWell(
                onTap: () {
                  setState(() {
                    _ratings[key] = _ratings[key] == starRating ? 0 : starRating;
                  });
                },
                child: Icon(
                  rating >= starRating ? Icons.star : Icons.star_border,
                  size: 32,
                  color: rating >= starRating
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _editPerformance(Performance performance) {
    setState(() {
      _showAddForm = true;
      _editingPerformanceId = performance.id;
      _selectedDate = performance.date;
      _ratings['serve'] = performance.serve;
      _ratings['smash'] = performance.smash;
      _ratings['footwork'] = performance.footwork;
      _ratings['defense'] = performance.defense;
      _ratings['stamina'] = performance.stamina;
      _commentController.text = performance.comments ?? '';
    });
  }

  Future<void> _savePerformance() async {
    // Validate that at least one skill is rated
    final hasRating = _ratings.values.any((rating) => rating > 0);
    if (!hasRating) {
      SuccessSnackbar.showError(context, 'Please rate at least one skill');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final dateString = _selectedDate.toIso8601String().split('T')[0];

      final performanceData = {
        'student_id': widget.student.id,
        'date': dateString,
        'serve': _ratings['serve'] ?? 0,
        'smash': _ratings['smash'] ?? 0,
        'footwork': _ratings['footwork'] ?? 0,
        'defense': _ratings['defense'] ?? 0,
        'stamina': _ratings['stamina'] ?? 0,
        'comments': _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      };

      if (_editingPerformanceId != null) {
        await performanceService.updatePerformance(_editingPerformanceId!, performanceData);
      } else {
        await performanceService.createPerformance(performanceData);
      }

      // Invalidate providers
      ref.invalidate(performanceByStudentProvider(widget.student.id));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _showAddForm = false;
          _editingPerformanceId = null;
          _ratings.updateAll((key, value) => 0);
          _commentController.clear();
          _selectedDate = DateTime.now();
        });
        SuccessSnackbar.show(
          context,
          _editingPerformanceId != null
              ? 'Performance updated successfully'
              : 'Performance saved successfully',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to save performance: ${e.toString()}');
      }
    }
  }

  Future<void> _deletePerformance(Performance performance) async {
    ConfirmationDialog.showDelete(
      context,
      'Performance Record',
      onConfirm: () async {
        setState(() => _isLoading = true);
        try {
          final performanceService = ref.read(performanceServiceProvider);
          await performanceService.deletePerformance(performance.id);
          
          // Invalidate providers
          ref.invalidate(performanceByStudentProvider(widget.student.id));

          if (mounted) {
            setState(() => _isLoading = false);
            SuccessSnackbar.show(context, 'Performance record deleted successfully');
          }
        } catch (e) {
          setState(() => _isLoading = false);
          if (mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete performance: ${e.toString()}');
          }
        }
      },
    );
  }
}
