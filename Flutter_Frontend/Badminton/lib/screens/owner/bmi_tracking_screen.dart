import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/more_screen_app_bar.dart';
import '../../providers/service_providers.dart';
import '../../providers/bmi_provider.dart';
import '../../providers/student_provider.dart';
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
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _showDropdown = false;
  String _selectedFilter = 'all'; // 'all', 'active', 'inactive'

  @override
  void initState() {
    super.initState();
    // Initialize with student if provided
    if (widget.initialStudent != null) {
      _initializeWithStudent(widget.initialStudent!);
    }
    
    // Setup focus listener
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() => _showDropdown = true);
      }
    });
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
        _searchController.text = student.name;
      });
      
      // Load BMI history
      await _loadBMIHistory();
      
      if (!mounted) return;
      setState(() => _isInitializing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isInitializing = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to initialize: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }
  
  void _selectStudent(Student student) {
    setState(() {
      _selectedStudentId = student.id;
      _selectedStudent = student;
      _searchController.text = student.name;
      _showDropdown = false;
      _searchFocusNode.unfocus();
    });
    _loadBMIHistory();
  }
  
  void _clearSelection() {
    setState(() {
      _selectedStudentId = null;
      _selectedStudent = null;
      _searchController.clear();
      _searchQuery = '';
      _bmiHistory = [];
    });
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
        SuccessSnackbar.showError(context, 'Failed to load BMI history: ${e.toString()}');
      }
    }
  }

  Future<void> _saveBMIRecord() async {
    if (_selectedStudentId == null) {
      SuccessSnackbar.showError(context, 'Please select a student');
      return;
    }

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
        SuccessSnackbar.show(context, _editingBMIRecordId != null
            ? 'BMI record updated successfully'
            : 'BMI record saved successfully');
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
        SuccessSnackbar.showError(context, 'Failed to save BMI record: ${e.toString()}');
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
        body: const Center(child: ListSkeleton(itemCount: 3)),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    void _handleReload() {
      if (_selectedStudentId != null) {
        ref.invalidate(bmiHistoryProvider(_selectedStudentId!));
      }
      ref.invalidate(allStudentsProvider);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: MoreScreenAppBar(
        title: 'BMI Tracking',
        onReload: _handleReload,
        isDark: isDark,
        additionalActions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? AppColors.accent : AppColorsLight.accent,
            ),
            onPressed: () {
              if (_selectedStudentId == null) {
                SuccessSnackbar.showError(context, 'Please select a student first');
                return;
              }
              setState(() => _showAddForm = true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _handleReload();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: GestureDetector(
          onTap: () {
            // Close dropdown when tapping outside
            if (_showDropdown) {
              setState(() {
                _showDropdown = false;
                _searchFocusNode.unfocus();
              });
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Selector
                GestureDetector(
                  onTap: () {}, // Prevent closing when tapping on the selector
                  child: _buildStudentSelector(),
                ),

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
                    const Center(child: ListSkeleton(itemCount: 3))
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
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Field
        NeumorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: _selectedStudent != null 
                  ? _selectedStudent!.name 
                  : 'Search students...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
              icon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty || _selectedStudent != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                      onPressed: () {
                        if (_selectedStudent != null) {
                          _clearSelection();
                        } else {
                          _clearSearch();
                        }
                      },
                    )
                  : null,
            ),
            onTap: () {
              setState(() => _showDropdown = true);
            },
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _showDropdown = true;
              });
            },
          ),
        ),
        
        // Filter Chips
        if (_showDropdown) ...[
          const SizedBox(height: AppDimensions.spacingM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                _FilterChip(
                  label: 'Active',
                  isSelected: _selectedFilter == 'active',
                  onTap: () => setState(() => _selectedFilter = 'active'),
                  color: AppColors.success,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                _FilterChip(
                  label: 'Inactive',
                  isSelected: _selectedFilter == 'inactive',
                  onTap: () => setState(() => _selectedFilter = 'inactive'),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
        
        // Dropdown List
        if (_showDropdown) ...[
          const SizedBox(height: AppDimensions.spacingM),
          _buildDropdownList(),
        ],
      ],
    );
  }
  
  Widget _buildDropdownList() {
    final studentsAsync = _searchQuery.isEmpty
        ? ref.watch(studentListProvider)
        : ref.watch(studentSearchProvider(_searchQuery));
    
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: studentsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppDimensions.paddingM),
          child: Center(child: ListSkeleton(itemCount: 3)),
        ),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: ErrorDisplay(
            message: 'Failed to load students',
            onRetry: () => ref.invalidate(studentListProvider),
          ),
        ),
        data: (allStudents) {
          // Apply status filter
          var filteredStudents = allStudents.where((student) {
            if (_selectedFilter == 'active') {
              return student.status == 'active';
            } else if (_selectedFilter == 'inactive') {
              return student.status == 'inactive';
            }
            return true;
          }).toList();

          // Sort filtered students alphabetically by name
          filteredStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          if (filteredStudents.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      _selectedFilter == 'active'
                          ? 'No active students found'
                          : _selectedFilter == 'inactive'
                              ? 'No inactive students found'
                              : 'No students found',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              final student = filteredStudents[index];
              return _buildStudentListItem(student);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildStudentListItem(Student student) {
    return InkWell(
      onTap: () => _selectStudent(student),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingM,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (student.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      student.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: student.status == 'active'
                    ? AppColors.success
                    : AppColors.error,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                student.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
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
                      ? const ListSkeleton(itemCount: 3)
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
    final widgetRef = ref;
    final isMounted = mounted;
    
    ConfirmationDialog.showDelete(
      context,
      'BMI Record',
      onConfirm: () async {
        setState(() => _isLoading = true);
        try {
          final bmiService = widgetRef.read(bmiServiceProvider);
          await bmiService.deleteBMIRecord(record.id);
          // Invalidate related providers
          if (_selectedStudentId != null) {
            widgetRef.invalidate(bmiByStudentProvider(_selectedStudentId!));
            widgetRef.invalidate(latestBmiProvider(_selectedStudentId!));
            widgetRef.invalidate(bmiTrendProvider(_selectedStudentId!));
          }
          if (isMounted && mounted) {
            SuccessSnackbar.show(context, 'BMI record deleted successfully');
            _loadBMIHistory();
          }
        } catch (e) {
          setState(() => _isLoading = false);
          if (isMounted && mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete BMI record: ${e.toString()}');
          }
        }
      },
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.accent).withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: isSelected ? (color ?? AppColors.accent) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? (color ?? AppColors.accent) : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
