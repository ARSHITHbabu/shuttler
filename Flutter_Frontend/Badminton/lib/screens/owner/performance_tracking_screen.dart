import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/service_providers.dart';
import '../../models/performance.dart';
import '../../models/student.dart';
import 'package:intl/intl.dart';

/// Performance Tracking Screen - Track student skill development
/// Matches React reference: PerformanceTracking.tsx
class PerformanceTrackingScreen extends ConsumerStatefulWidget {
  const PerformanceTrackingScreen({super.key});

  @override
  ConsumerState<PerformanceTrackingScreen> createState() => _PerformanceTrackingScreenState();
}

class _PerformanceTrackingScreenState extends ConsumerState<PerformanceTrackingScreen> {
  int? _selectedStudentId;
  Student? _selectedStudent;
  bool _showAddForm = false;
  DateTime _selectedDate = DateTime.now();
  final Map<String, int> _skillRatings = {
    'serve': 0,
    'smash': 0,
    'footwork': 0,
    'defense': 0,
    'stamina': 0,
  };
  final _commentsController = TextEditingController();
  List<Performance> _performanceHistory = [];
  bool _isLoading = false;
  int? _editingPerformanceId; // Track if we're editing an existing record

  final List<Map<String, dynamic>> _skills = [
    {'key': 'serve', 'label': 'Serve', 'icon': Icons.sports_tennis},
    {'key': 'smash', 'label': 'Smash', 'icon': Icons.flash_on},
    {'key': 'footwork', 'label': 'Footwork', 'icon': Icons.directions_run},
    {'key': 'defense', 'label': 'Defense', 'icon': Icons.shield},
    {'key': 'stamina', 'label': 'Stamina', 'icon': Icons.fitness_center},
  ];

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadPerformanceHistory() async {
    if (_selectedStudentId == null) return;

    setState(() => _isLoading = true);
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final records = await performanceService.getPerformanceRecords(
        studentId: _selectedStudentId,
      );
      setState(() {
        _performanceHistory = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load performance history: $e')),
        );
      }
    }
  }

  void _editPerformance(Performance performance) {
    setState(() {
      _showAddForm = true;
      _selectedDate = performance.date;
      _skillRatings['serve'] = performance.serve;
      _skillRatings['smash'] = performance.smash;
      _skillRatings['footwork'] = performance.footwork;
      _skillRatings['defense'] = performance.defense;
      _skillRatings['stamina'] = performance.stamina;
      _commentsController.text = performance.comments ?? '';
      _editingPerformanceId = performance.id;
    });
  }

  Future<void> _deletePerformance(Performance performance) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Performance Record', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to delete this performance record?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final performanceService = ref.read(performanceServiceProvider);
        await performanceService.deletePerformance(performance.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Performance record deleted successfully')),
          );
          _loadPerformanceHistory();
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete performance: $e')),
          );
        }
      }
    }
  }

  Future<void> _savePerformance() async {
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
      );
      return;
    }

    // Validate ratings
    bool hasRating = false;
    for (var rating in _skillRatings.values) {
      if (rating > 0) {
        hasRating = true;
        break;
      }
    }

    if (!hasRating) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate at least one skill')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final performanceData = {
        'student_id': _selectedStudentId,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'serve': _skillRatings['serve'] ?? 0,
        'smash': _skillRatings['smash'] ?? 0,
        'footwork': _skillRatings['footwork'] ?? 0,
        'defense': _skillRatings['defense'] ?? 0,
        'stamina': _skillRatings['stamina'] ?? 0,
        'comments': _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
      };

      if (_editingPerformanceId != null) {
        await performanceService.updatePerformance(_editingPerformanceId!, performanceData);
      } else {
        await performanceService.createPerformance(performanceData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingPerformanceId != null
              ? 'Performance record updated successfully'
              : 'Performance record saved successfully')),
        );
        setState(() {
          _showAddForm = false;
          _skillRatings.updateAll((key, value) => 0);
          _commentsController.clear();
          _selectedDate = DateTime.now();
          _editingPerformanceId = null;
        });
        _loadPerformanceHistory();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save performance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      return _buildAddForm();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Performance Tracking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: () {
              if (_selectedStudentId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a student first')),
                );
                return;
              }
              setState(() => _showAddForm = true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Selector
              _buildStudentSelector(),

              if (_selectedStudentId != null) ...[
                const SizedBox(height: AppDimensions.spacingL),

                // Progress Chart
                if (_performanceHistory.length >= 2) ...[
                  const Text(
                    'Progress Chart',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildProgressChart(),
                  const SizedBox(height: AppDimensions.spacingL),
                ],

                // Performance History
                const Text(
                  'Performance History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),

                if (_isLoading)
                  const Center(child: LoadingSpinner())
                else if (_performanceHistory.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.assessment_outlined,
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
                  )
                else
                  ..._performanceHistory.map((performance) => _buildPerformanceCard(performance)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentSelector() {
    return FutureBuilder<List<Student>>(
      future: ref.read(studentServiceProvider).getStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSpinner();
        }

        if (snapshot.hasError) {
          return ErrorDisplay(
            message: 'Failed to load students',
            onRetry: () => setState(() {}),
          );
        }

        final students = snapshot.data ?? [];
        if (students.isEmpty) {
          return const Text(
            'No students available',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }

        return NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: DropdownButtonFormField<int>(
            value: _selectedStudentId,
            decoration: const InputDecoration(
              labelText: 'Select Student',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.cardBackground,
            style: const TextStyle(color: AppColors.textPrimary),
            items: students.map((student) {
              return DropdownMenuItem<int>(
                value: student.id,
                child: Text(student.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStudentId = value;
                _selectedStudent = students.firstWhere((s) => s.id == value);
              });
              _loadPerformanceHistory();
            },
          ),
        );
      },
    );
  }

  Widget _buildAddForm() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => setState(() => _showAddForm = false),
        ),
        title: Text(
          _editingPerformanceId != null ? 'Edit Performance' : 'Add Performance',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info
              if (_selectedStudent != null)
                NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
                  child: Text(
                    'Student: ${_selectedStudent!.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

              // Date Picker
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
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

              // Skills Rating
              const Text(
                'Rate Skills (1-5)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              ..._skills.map((skill) => _buildSkillRatingCard(skill)),

              const SizedBox(height: AppDimensions.spacingL),

              // Comments
              CustomTextField(
                controller: _commentsController,
                label: 'Comments',
                hint: 'Add comments...',
                maxLines: 4,
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
                      ? const LoadingSpinner()
                      : Text(
                          _editingPerformanceId != null ? 'Update Performance' : 'Save Performance',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillRatingCard(Map<String, dynamic> skill) {
    final key = skill['key'] as String;
    final label = skill['label'] as String;
    final icon = skill['icon'] as IconData;
    final rating = _skillRatings[key] ?? 0;

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
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: List.generate(5, (index) {
              final starRating = index + 1;
              final isSelected = rating >= starRating;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _skillRatings[key] = starRating;
                      });
                    },
                    child: NeumorphicContainer(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                      child: Center(
                        child: Text(
                          '$starRating',
                          style: TextStyle(
                            color: isSelected ? AppColors.accent : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
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
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
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
            Text(
              performance.comments!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
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
                color: index < rating ? AppColors.warning : AppColors.textSecondary,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    if (_performanceHistory.length < 2) {
      return const SizedBox.shrink();
    }

    // Sort by date
    final sortedHistory = List<Performance>.from(_performanceHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Prepare data for chart - average rating over time
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
}
