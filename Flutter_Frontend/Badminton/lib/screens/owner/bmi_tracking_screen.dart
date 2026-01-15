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
import '../../models/bmi_record.dart';
import '../../models/student.dart';
import 'package:intl/intl.dart';

/// BMI Tracking Screen - Track student health metrics
/// Matches React reference: BMITracking.tsx
class BMITrackingScreen extends ConsumerStatefulWidget {
  final Student? initialStudent;
  
  const BMITrackingScreen({
    super.key,
    this.initialStudent,
  });

  @override
  ConsumerState<BMITrackingScreen> createState() => _BMITrackingScreenState();
}

class _BMITrackingScreenState extends ConsumerState<BMITrackingScreen> {
  int? _selectedStudentId;
  Student? _selectedStudent;
  bool _showAddForm = false;
  DateTime _selectedDate = DateTime.now();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  List<BMIRecord> _bmiHistory = [];
  bool _isLoading = false;
  double? _calculatedBMI;
  String? _healthStatus;
  int? _editingBMIRecordId; // Track if we're editing an existing record
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    // Initialize with student if provided
    if (widget.initialStudent != null) {
      _initializeWithStudent(widget.initialStudent!);
    }
  }

  Future<void> _initializeWithStudent(Student student) async {
    if (!mounted) return;
    setState(() => _isInitializing = true);
    try {
      // Pre-select the student
      if (!mounted) return;
      setState(() {
        _selectedStudentId = student.id;
        _selectedStudent = student;
      });
      
      // Load BMI history
      await _loadBMIHistory();
      
      if (!mounted) return;
      setState(() => _isInitializing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isInitializing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e')),
        );
      }
    }
  }

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

  Future<void> _loadBMIHistory() async {
    if (_selectedStudentId == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final bmiService = ref.read(bmiServiceProvider);
      final records = await bmiService.getBMIRecords(
        studentId: _selectedStudentId,
      );
      if (!mounted) return;
      setState(() {
        _bmiHistory = records;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load BMI history: $e')),
        );
      }
    }
  }

  Future<void> _saveBMIRecord() async {
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
      );
      return;
    }

    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter height and weight')),
      );
      return;
    }

    try {
      final height = double.parse(heightText);
      final weight = double.parse(weightText);

      if (height <= 0 || weight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Height and weight must be greater than 0')),
        );
        return;
      }

      setState(() => _isLoading = true);
      final bmiService = ref.read(bmiServiceProvider);
      final bmiData = {
        'student_id': _selectedStudentId,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'height': height,
        'weight': weight,
      };

      if (_editingBMIRecordId != null) {
        await bmiService.updateBMIRecord(_editingBMIRecordId!, bmiData);
      } else {
        await bmiService.createBMIRecord(bmiData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingBMIRecordId != null
              ? 'BMI record updated successfully'
              : 'BMI record saved successfully')),
        );
        setState(() {
          _showAddForm = false;
          _heightController.clear();
          _weightController.clear();
          _calculatedBMI = null;
          _healthStatus = null;
          _selectedDate = DateTime.now();
          _editingBMIRecordId = null;
        });
        _loadBMIHistory();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save BMI record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      return _buildAddForm();
    }

    // Show loading during initialization
    if (_isInitializing) {
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
            'BMI Tracking',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: LoadingSpinner()),
      );
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
          'BMI Tracking',
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

                // BMI Trend Chart
                if (_bmiHistory.length >= 2) ...[
                  const Text(
                    'BMI Trend Chart',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildBMITrendChart(),
                  const SizedBox(height: AppDimensions.spacingL),
                ],

                // BMI History
                const Text(
                  'BMI History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),

                if (_isLoading)
                  const Center(child: LoadingSpinner())
                else if (_bmiHistory.isEmpty)
                  Center(
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
                  )
                else
                  ..._bmiHistory.map((record) => _buildBMICard(record)),
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
              _loadBMIHistory();
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
          _editingBMIRecordId != null ? 'Edit BMI Record' : 'Add BMI Record',
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
                      ? const LoadingSpinner()
                      : Text(
                          _editingBMIRecordId != null ? 'Update BMI Record' : 'Save BMI Record',
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

  void _editBMIRecord(BMIRecord record) {
    setState(() {
      _showAddForm = true;
      _selectedDate = record.date;
      _heightController.text = record.height.toString();
      _weightController.text = record.weight.toString();
      _calculateBMI();
      _editingBMIRecordId = record.id;
    });
  }

  Future<void> _deleteBMIRecord(BMIRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete BMI Record', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to delete this BMI record?', style: TextStyle(color: AppColors.textSecondary)),
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
        final bmiService = ref.read(bmiServiceProvider);
        await bmiService.deleteBMIRecord(record.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('BMI record deleted successfully')),
          );
          _loadBMIHistory();
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete BMI record: $e')),
          );
        }
      }
    }
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
          // Achievement message for underweight/overweight/obese
          if (record.healthStatus != null)
            Builder(
              builder: (context) {
                final achievementMsg = BMIRecord.getAchievementMessage(record.bmi);
                if (achievementMsg != null) {
                  return _buildAchievementLabel(achievementMsg);
                }
                return const SizedBox.shrink();
              },
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

  Widget _buildAchievementLabel(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: AppColors.accent.withOpacity(0.7),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildBMITrendChart() {
    if (_bmiHistory.length < 2) {
      return const SizedBox.shrink();
    }

    // Sort by date
    final sortedHistory = List<BMIRecord>.from(_bmiHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Prepare data for chart - BMI over time
    final spots = sortedHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.bmi.toDouble());
    }).toList();

    // Calculate min and max BMI for Y axis
    final minBMI = sortedHistory.map((r) => r.bmi).reduce((a, b) => a < b ? a : b);
    final maxBMI = sortedHistory.map((r) => r.bmi).reduce((a, b) => a > b ? a : b);
    final yMin = (minBMI - 2.0).clamp(0.0, double.infinity) as double;
    final yMax = (maxBMI + 2.0) as double;

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
                // Add reference lines for BMI categories
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipBgColor: AppColors.cardBackground,
                  ),
                ),
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
}
