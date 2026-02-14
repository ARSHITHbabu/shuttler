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
import '../../../providers/bmi_provider.dart';
import '../../../models/bmi_record.dart';
import '../../../models/student.dart';
import 'package:intl/intl.dart';

/// BMI Tab - Shows BMI history, charts, and allows adding/editing records
class StudentBMITab extends ConsumerStatefulWidget {
  final Student student;

  const StudentBMITab({
    super.key,
    required this.student,
  });

  @override
  ConsumerState<StudentBMITab> createState() => _StudentBMITabState();
}

class _StudentBMITabState extends ConsumerState<StudentBMITab> {
  bool _showAddForm = false;
  DateTime _selectedDate = DateTime.now();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = false;
  int? _editingBMIRecordId;
  double? _calculatedBMI;
  String? _healthStatus;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty) {
      setState(() {
        _calculatedBMI = null;
        _healthStatus = null;
      });
      return;
    }

    try {
      final height = double.parse(heightText);
      final weight = double.parse(weightText);

      if (height > 0 && weight > 0) {
        final bmi = BMIRecord.calculateBMI(height, weight);
        final status = BMIRecord.getHealthStatus(bmi);
        setState(() {
          _calculatedBMI = bmi;
          _healthStatus = status;
        });
      }
    } catch (e) {
      setState(() {
        _calculatedBMI = null;
        _healthStatus = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      return _buildAddForm();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'BMI Records',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showAddForm = true),
                icon: const Icon(Icons.add, size: 18),
                label: Text(isSmallScreen ? 'Add' : 'Add Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
          
          // BMI History
          _buildBMIHistory(),
        ],
      ),
    );
  }

  Widget _buildBMIHistory() {
    final bmiAsync = ref.watch(bmiByStudentProvider(widget.student.id));

    return bmiAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Failed to load BMI records: ${error.toString()}',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(
                  Icons.monitor_weight_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                const Text(
                  'No BMI records yet',
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
        final sortedRecords = List<BMIRecord>.from(records)
          ..sort((a, b) => b.date.compareTo(a.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI Trend Chart (if 2+ records)
            if (sortedRecords.length >= 2) ...[
              _buildBMITrendChart(sortedRecords),
              const SizedBox(height: AppDimensions.spacingL),
            ],
            
            // Records List
            ...sortedRecords.map((record) => _buildBMICard(record)),
          ],
        );
      },
    );
  }

  Widget _buildBMITrendChart(List<BMIRecord> records) {
    // Sort by date ascending for chart
    final sortedHistory = List<BMIRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.bmi.toDouble());
    }).toList();

    // Calculate min and max BMI for Y axis
    final minBMI = sortedHistory.map((r) => r.bmi).reduce((a, b) => a < b ? a : b);
    final maxBMI = sortedHistory.map((r) => r.bmi).reduce((a, b) => a > b ? a : b);
    final yMin = (minBMI - 2.0).clamp(0.0, double.infinity);
    final yMax = (maxBMI + 2.0);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BMI Trend Over Time',
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
                  horizontalInterval: 2,
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
                      interval: 2,
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
                minY: yMin,
                maxY: yMax,
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
                        final record = sortedHistory[index];
                        return FlDotCirclePainter(
                          radius: 4,
                          color: _getHealthStatusColor(record.healthStatus ?? 'normal'),
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
          const SizedBox(height: AppDimensions.spacingS),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue, 'Underweight'),
              const SizedBox(width: AppDimensions.spacingM),
              _buildLegendItem(AppColors.success, 'Normal'),
              const SizedBox(width: AppDimensions.spacingM),
              _buildLegendItem(AppColors.warning, 'Overweight'),
              const SizedBox(width: AppDimensions.spacingM),
              _buildLegendItem(AppColors.error, 'Obese'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBMICard(BMIRecord record) {
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
                DateFormat('dd MMM, yyyy').format(record.date),
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
                      color: _getHealthStatusColor(record.healthStatus ?? 'normal').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      record.healthStatus?.toUpperCase() ?? 'NORMAL',
                      style: TextStyle(
                        color: _getHealthStatusColor(record.healthStatus ?? 'normal'),
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
                            _editBMIRecord(record);
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
                            _deleteBMIRecord(record);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Height', '${record.height.toStringAsFixed(1)} cm'),
              _buildInfoItem('Weight', '${record.weight.toStringAsFixed(1)} kg'),
              _buildInfoItem('BMI', record.bmi.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
                _editingBMIRecordId != null ? 'Edit BMI Record' : 'Add BMI Record',
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
                    _editingBMIRecordId = null;
                    _heightController.clear();
                    _weightController.clear();
                    _calculatedBMI = null;
                    _healthStatus = null;
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
          
          // Height Input
          CustomTextField(
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'Enter height in centimeters',
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateBMI(),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          
          // Weight Input
          CustomTextField(
            controller: _weightController,
            label: 'Weight (kg)',
            hint: 'Enter weight in kilograms',
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateBMI(),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // BMI Display
          if (_calculatedBMI != null)
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
              child: Column(
                children: [
                  Text(
                    'BMI: ${_calculatedBMI!.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: _getHealthStatusColor(_healthStatus!).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      _healthStatus!.toUpperCase(),
                      style: TextStyle(
                        color: _getHealthStatusColor(_healthStatus!),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveBMIRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _editingBMIRecordId != null ? 'Update BMI Record' : 'Save BMI Record',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _editBMIRecord(BMIRecord record) {
    setState(() {
      _showAddForm = true;
      _editingBMIRecordId = record.id;
      _selectedDate = record.date;
      _heightController.text = record.height.toString();
      _weightController.text = record.weight.toString();
      _calculateBMI();
    });
  }

  Future<void> _saveBMIRecord() async {
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty) {
      SuccessSnackbar.showError(context, 'Please enter height and weight');
      return;
    }

    try {
      final height = double.parse(heightText);
      final weight = double.parse(weightText);

      if (height <= 0 || weight <= 0) {
        SuccessSnackbar.showError(context, 'Height and weight must be greater than 0');
        return;
      }

      setState(() => _isLoading = true);
      final bmiService = ref.read(bmiServiceProvider);
      final bmiData = {
        'student_id': widget.student.id,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'height': height,
        'weight': weight,
      };

      if (_editingBMIRecordId != null) {
        await bmiService.updateBMIRecord(_editingBMIRecordId!, bmiData);
      } else {
        await bmiService.createBMIRecord(bmiData);
      }

      // Invalidate providers
      ref.invalidate(bmiByStudentProvider(widget.student.id));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _showAddForm = false;
          _heightController.clear();
          _weightController.clear();
          _calculatedBMI = null;
          _healthStatus = null;
          _selectedDate = DateTime.now();
          _editingBMIRecordId = null;
        });
        SuccessSnackbar.show(
          context,
          _editingBMIRecordId != null
              ? 'BMI record updated successfully'
              : 'BMI record saved successfully',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to save BMI record: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteBMIRecord(BMIRecord record) async {
    ConfirmationDialog.showDelete(
      context,
      'BMI Record',
      onConfirm: () async {
        setState(() => _isLoading = true);
        try {
          final bmiService = ref.read(bmiServiceProvider);
          await bmiService.deleteBMIRecord(record.id);
          
          // Invalidate providers
          ref.invalidate(bmiByStudentProvider(widget.student.id));

          if (mounted) {
            setState(() => _isLoading = false);
            SuccessSnackbar.show(context, 'BMI record deleted successfully');
          }
        } catch (e) {
          setState(() => _isLoading = false);
          if (mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete BMI record: ${e.toString()}');
          }
        }
      },
    );
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'underweight':
        return Colors.blue;
      case 'normal':
        return AppColors.success;
      case 'overweight':
        return AppColors.warning;
      case 'obese':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
