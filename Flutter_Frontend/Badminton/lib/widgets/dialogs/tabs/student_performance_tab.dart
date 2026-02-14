import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int? _selectedBatchId;
  String? _selectedBatchName;
  List<dynamic> _studentBatches = [];

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final horizontalPadding = isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL;
    
    if (_showAddForm) {
      return _buildAddForm();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Performance Records',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  // Fetch student batches if not already fetched
                  if (_studentBatches.isEmpty) {
                    setState(() => _isLoading = true);
                    try {
                      final batchService = ref.read(batchServiceProvider);
                      _studentBatches = await batchService.getStudentBatches(widget.student.id);
                      if (_studentBatches.isNotEmpty) {
                        _selectedBatchId = _studentBatches.first.id;
                        _selectedBatchName = _studentBatches.first.batchName;
                      }
                    } catch (e) {
                      debugPrint('Error fetching student batches: $e');
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                  setState(() => _showAddForm = true);
                },
                icon: Icon(Icons.add, size: isSmallScreen ? 16 : 18),
                label: Text(
                  isSmallScreen ? 'Add' : 'Add Record',
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
          
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

        // Group records by batch for better display
        final Map<int, List<Performance>> recordsByBatch = {};
        for (final record in records) {
          recordsByBatch.putIfAbsent(record.batchId, () => []).add(record);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SINGLE OVERALL GRAPH
            if (records.length >= 2) ...[
              _buildProgressChart(records, isOverall: true),
              const SizedBox(height: AppDimensions.spacingL),
            ],

            // Batch-wise History (List only, no separate graphs)
            ...recordsByBatch.entries.map((entry) {
              final batchRecords = entry.value;
              final batchName = batchRecords.first.batchName ?? 'Batch ${entry.key}';
              
              // Sort by date descending for list
              final sortedRecords = List<Performance>.from(batchRecords)
                ..sort((a, b) => b.date.compareTo(a.date));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      batchName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  
                  // Records List for this batch
                  ...sortedRecords.map((performance) => _buildPerformanceCard(performance)),
                  const SizedBox(height: AppDimensions.spacingL),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildProgressChart(List<Performance> records, {bool isOverall = false}) {
    // Sort by date ascending for chart
    final sortedHistory = List<Performance>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Prepare data for each skill
    final serveSpots = <FlSpot>[];
    final smashSpots = <FlSpot>[];
    final footworkSpots = <FlSpot>[];
    final defenseSpots = <FlSpot>[];
    final staminaSpots = <FlSpot>[];
    final avgSpots = <FlSpot>[];

    for (int i = 0; i < sortedHistory.length; i++) {
      final p = sortedHistory[i];
      final x = i.toDouble();
      serveSpots.add(FlSpot(x, p.serve.toDouble()));
      smashSpots.add(FlSpot(x, p.smash.toDouble()));
      footworkSpots.add(FlSpot(x, p.footwork.toDouble()));
      defenseSpots.add(FlSpot(x, p.defense.toDouble()));
      staminaSpots.add(FlSpot(x, p.stamina.toDouble()));
      avgSpots.add(FlSpot(x, p.averageRating));
    }

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverall ? 'Overall Performance Trends' : 'Skill Trends',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              if (!isOverall && sortedHistory.any((element) => element.batchName != null))
                Text(
                  sortedHistory.first.batchName ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.cardBackground.withOpacity(0.9),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        String skill = 'Skill';
                        switch (spot.barIndex) {
                          case 0: skill = 'Avg'; break;
                          case 1: skill = 'Serve'; break;
                          case 2: skill = 'Smash'; break;
                          case 3: skill = 'Footwork'; break;
                          case 4: skill = 'Defense'; break;
                          case 5: skill = 'Stamina'; break;
                        }
                        return LineTooltipItem(
                          '$skill: ${spot.y.toStringAsFixed(1)}',
                          TextStyle(
                            color: spot.bar.color ?? AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value > 5) return const Text('');
                        return Text(
                          value.toInt().toString(),
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
                maxY: 5.2,
                lineBarsData: [
                  _createLineData(avgSpots, AppColors.accent, isMain: true),
                  _createLineData(serveSpots, Colors.blue),
                  _createLineData(smashSpots, Colors.red),
                  _createLineData(footworkSpots, Colors.green),
                  _createLineData(defenseSpots, Colors.orange),
                  _createLineData(staminaSpots, Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Legend
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildLegendItem('Avg', AppColors.accent, isMain: true),
              _buildLegendItem('Serve', Colors.blue),
              _buildLegendItem('Smash', Colors.red),
              _buildLegendItem('Foot', Colors.green),
              _buildLegendItem('Def', Colors.orange),
              _buildLegendItem('Stam', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _createLineData(List<FlSpot> spots, Color color, {bool isMain = false}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: isMain ? 3 : 1.5,
      isStrokeCapRound: true,
      dotData: FlDotData(show: isMain),
      belowBarData: BarAreaData(
        show: isMain,
        color: color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isMain = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: isMain ? 3 : 1.5,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: AppColors.textSecondary,
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(Performance performance) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingS : AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM, yyyy').format(performance.date),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (performance.batchName != null)
                      Text(
                        performance.batchName!,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      'Avg: ${performance.averageRating.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    padding: EdgeInsets.zero,
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
          SizedBox(height: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
          _buildSkillRow('Serve', performance.serve),
          _buildSkillRow('Smash', performance.smash),
          _buildSkillRow('Footwork', performance.footwork),
          _buildSkillRow('Defense', performance.defense),
          _buildSkillRow('Stamina', performance.stamina),
          if (performance.comments != null && performance.comments!.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
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
                          fontSize: isSmallScreen ? 11 : 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        performance.comments!,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isSmallScreen ? 13 : 14,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final horizontalPadding = isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _editingPerformanceId != null ? 'Edit Performance' : 'Add Performance',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
          SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
          
          // Batch Selector (if multiple batches)
          if (_studentBatches.length > 1) ...[
            const Text(
              'Select Batch',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedBatchId,
                  isExpanded: true,
                  dropdownColor: AppColors.cardBackground,
                  items: _studentBatches.map((batch) {
                    return DropdownMenuItem<int>(
                      value: batch.id,
                      child: Text(
                        batch.batchName,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedBatchId = value;
                        _selectedBatchName = _studentBatches
                            .firstWhere((b) => b.id == value)
                            .batchName;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // Date Picker
          const Text(
            'Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
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
      _selectedBatchId = performance.batchId;
      _selectedBatchName = performance.batchName;
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
        'batch_id': _selectedBatchId,
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
