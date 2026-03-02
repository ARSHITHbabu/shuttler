import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/service_providers.dart';
import '../../providers/performance_provider.dart';
import '../../providers/batch_provider.dart';
import '../../models/performance.dart';
import '../../models/student.dart';
import '../../models/batch.dart';
import 'package:intl/intl.dart';

/// Performance Tracking Screen - Track student skill development
/// New flow: Select Batch -> Select Student -> View History OR Add Performance (table format)
class PerformanceTrackingScreen extends ConsumerStatefulWidget {
  final Student? initialStudent;
  
  const PerformanceTrackingScreen({
    super.key,
    this.initialStudent,
  });

  @override
  ConsumerState<PerformanceTrackingScreen> createState() =>
      _PerformanceTrackingScreenState();
}

class _PerformanceTrackingScreenState
    extends ConsumerState<PerformanceTrackingScreen> {
  int? _selectedBatchId;
  int? _selectedStudentId;
  bool _showAddForm = false;
  DateTime _selectedDate = DateTime.now();
  List<Performance> _performanceHistory = [];
  bool _isLoading = false;
  List<Student> _batchStudents = [];
  bool _loadingStudents = false;
  bool _isInitializing = false;

  // Table form data for bulk entry
  final Map<int, Map<String, dynamic>> _tableData =
      {}; // studentId -> {skill ratings + comments}
  final Map<int, TextEditingController> _commentControllers =
      {}; // studentId -> TextEditingController

  final List<Map<String, dynamic>> _skills = [
    {'key': 'serve', 'label': 'Serve', 'icon': Icons.sports_tennis},
    {'key': 'smash', 'label': 'Smash', 'icon': Icons.flash_on},
    {'key': 'footwork', 'label': 'Footwork', 'icon': Icons.directions_run},
    {'key': 'defense', 'label': 'Defense', 'icon': Icons.shield},
    {'key': 'stamina', 'label': 'Stamina', 'icon': Icons.fitness_center},
  ];

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
      // Get student's batches
      final studentBatches = await ref.read(studentBatchesProvider(student.id).future);

      if (!mounted) return;
      if (studentBatches.isEmpty) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Student is not enrolled in any batches');
        }
        if (mounted) {
          setState(() => _isInitializing = false);
        }
        return;
      }

      // Pre-select the first batch
      final firstBatch = studentBatches.first;
      if (!mounted) return;
      setState(() {
        _selectedBatchId = firstBatch.id;
        _selectedStudentId = student.id;
      });

      // Load batch students
      await _loadBatchStudents(keepStudentSelection: true);
      
      // Load performance history
      await _loadPerformanceHistory();
      
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
    // Dispose comment controllers
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    _commentControllers.clear();
    super.dispose();
  }

  Future<void> _loadBatchStudents({bool keepStudentSelection = false}) async {
    if (_selectedBatchId == null) {
      if (!mounted) return;
      setState(() {
        _batchStudents = [];
        if (!keepStudentSelection) {
          _selectedStudentId = null;
          _performanceHistory = [];
        }
      });
      return;
    }

    if (!mounted) return;
    setState(() => _loadingStudents = true);
    try {
      final batchService = ref.read(batchServiceProvider);
      final students = await batchService.getBatchStudents(_selectedBatchId!);
      if (!mounted) return;
      setState(() {
        _batchStudents = students;
        _loadingStudents = false;
        // Reset student selection when batch changes (unless we're keeping it)
        if (!keepStudentSelection) {
          _selectedStudentId = null;
          _performanceHistory = [];
        } else {
          // Verify the selected student is still in this batch
          if (_selectedStudentId != null) {
            final studentExists = students.any((s) => s.id == _selectedStudentId);
            if (!studentExists) {
              _selectedStudentId = null;
              _performanceHistory = [];
            }
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStudents = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to load students: ${e.toString()}');
      }
    }
  }

  Future<void> _loadPerformanceHistory() async {
    if (_selectedStudentId == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final records = await performanceService.getPerformanceRecords(
        studentId: _selectedStudentId,
        batchId: _selectedBatchId,
      );
      if (!mounted) return;
      setState(() {
        _performanceHistory = records;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to load performance history: ${e.toString()}');
      }
    }
  }

  Future<void> _deletePerformance(Performance performance) async {
    final widgetRef = ref;
    final isMounted = mounted;
    
    ConfirmationDialog.showDelete(
      context,
      'Performance Record',
      onConfirm: () async {
        setState(() => _isLoading = true);
        try {
          final performanceService = widgetRef.read(performanceServiceProvider);
          await performanceService.deletePerformance(performance.id);
          // Invalidate related providers
          if (_selectedStudentId != null) {
            widgetRef.invalidate(performanceByStudentProvider(_selectedStudentId!));
            widgetRef.invalidate(averagePerformanceProvider(_selectedStudentId!));
            widgetRef.invalidate(latestPerformanceProvider(_selectedStudentId!));
          }
          if (isMounted && mounted) {
            SuccessSnackbar.show(context, 'Performance record deleted successfully');
            _loadPerformanceHistory();
          }
        } catch (e) {
          setState(() => _isLoading = false);
          if (isMounted && mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete performance: ${e.toString()}');
          }
        }
      },
    );
  }

  void _openAddForm() async {
    // Clear previous form data
    _tableData.clear();
    // Dispose old controllers
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    _commentControllers.clear();

    setState(() {
      _showAddForm = true;
      _selectedDate = DateTime.now();
    });

    // If a batch is already selected, load its students
    if (_selectedBatchId != null) {
      await _loadBatchStudentsForForm();
      _initializeTableData();
    }
  }

  void _initializeTableData() {
    if (_batchStudents.isEmpty) return;

    // Initialize table data for all students
    _tableData.clear();
    // Dispose old controllers
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    _commentControllers.clear();

    for (var student in _batchStudents) {
      _tableData[student.id] = {
        'serve': 0,
        'smash': 0,
        'footwork': 0,
        'defense': 0,
        'stamina': 0,
        'comments': '',
      };
      // Create controller for comments
      _commentControllers[student.id] = TextEditingController();
    }
  }

  Future<void> _saveBulkPerformance() async {
    // Validate that at least one student has ratings
    bool hasAnyRating = false;
    for (var studentData in _tableData.values) {
      if (studentData['serve'] > 0 ||
          studentData['smash'] > 0 ||
          studentData['footwork'] > 0 ||
          studentData['defense'] > 0 ||
          studentData['stamina'] > 0) {
        hasAnyRating = true;
        break;
      }
    }

    if (!hasAnyRating) {
      SuccessSnackbar.showError(context, 'Please rate at least one skill for at least one student');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final dateString = _selectedDate.toIso8601String().split('T')[0];

      // Save performance for each student
      int successCount = 0;
      int failCount = 0;

      for (var entry in _tableData.entries) {
        final studentId = entry.key;
        final data = entry.value;

        // Skip if no ratings
        if (data['serve'] == 0 &&
            data['smash'] == 0 &&
            data['footwork'] == 0 &&
            data['defense'] == 0 &&
            data['stamina'] == 0) {
          continue;
        }

        try {
          final performanceData = {
            'student_id': studentId,
            'batch_id': _selectedBatchId,
            'date': dateString,
            'serve': data['serve'] ?? 0,
            'smash': data['smash'] ?? 0,
            'footwork': data['footwork'] ?? 0,
            'defense': data['defense'] ?? 0,
            'stamina': data['stamina'] ?? 0,
            'comments': (data['comments'] as String?)?.trim().isEmpty == true
                ? null
                : (data['comments'] as String?)?.trim(),
          };

          await performanceService.createPerformance(performanceData);
          successCount++;
        } catch (e) {
          failCount++;
          // Continue with other students even if one fails
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _showAddForm = false;
          _tableData.clear();
          // Dispose controllers
          for (var controller in _commentControllers.values) {
            controller.dispose();
          }
          _commentControllers.clear();
        });

        if (failCount == 0) {
          SuccessSnackbar.show(context, 'Performance records saved successfully for $successCount student(s)');
        } else {
          SuccessSnackbar.showError(context, 'Saved $successCount record(s), $failCount failed');
        }

        // Reload history if a student was selected
        if (_selectedStudentId != null) {
          _loadPerformanceHistory();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to save performance: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      return _buildTableForm();
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
            'Performance Tracking',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: ListSkeleton(itemCount: 5)),
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
            onPressed: _openAddForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Batch Selector
              _buildBatchSelector(),

              if (_selectedBatchId != null) ...[
                const SizedBox(height: AppDimensions.spacingL),
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
                    const Center(child: ListSkeleton(itemCount: 3))
                  else if (_performanceHistory.isEmpty)
                    EmptyState.noPerformance()
                  else
                    ..._performanceHistory.map(
                      (performance) => _buildPerformanceCard(performance),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchSelector() {
    return FutureBuilder<List<Batch>>(
      future: ref.read(batchServiceProvider).getBatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListSkeleton(itemCount: 3);
        }

        if (snapshot.hasError) {
          return ErrorDisplay(
            message: 'Failed to load batches',
            onRetry: () => setState(() {}),
          );
        }

        final batches = snapshot.data ?? [];
        if (batches.isEmpty) {
          return const Text(
            'No batches available',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }

        return NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedBatchId,
            decoration: const InputDecoration(
              labelText: 'Select Batch',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.cardBackground,
            style: const TextStyle(color: AppColors.textPrimary),
            items: batches.map((batch) {
              return DropdownMenuItem<int>(
                value: batch.id,
                child: Text(batch.batchName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBatchId = value;
              });
              _loadBatchStudents(keepStudentSelection: false);
            },
          ),
        );
      },
    );
  }

  Widget _buildBatchSelectorInForm() {
    return FutureBuilder<List<Batch>>(
      future: ref.read(batchServiceProvider).getBatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListSkeleton(itemCount: 3);
        }

        if (snapshot.hasError) {
          return ErrorDisplay(
            message: 'Failed to load batches',
            onRetry: () => setState(() {}),
          );
        }

        final batches = snapshot.data ?? [];
        if (batches.isEmpty) {
          return const Text(
            'No batches available',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }

        return NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedBatchId,
            decoration: const InputDecoration(
              labelText: 'Select Batch',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.cardBackground,
            style: const TextStyle(color: AppColors.textPrimary),
            items: batches.map((batch) {
              return DropdownMenuItem<int>(
                value: batch.id,
                child: Text(batch.batchName),
              );
            }).toList(),
            onChanged: (value) async {
              setState(() {
                _selectedBatchId = value;
              });
              // Load students for the selected batch
              await _loadBatchStudentsForForm();
              // Initialize table data with new students
              _initializeTableData();
            },
          ),
        );
      },
    );
  }

  Future<void> _loadBatchStudentsForForm() async {
    if (_selectedBatchId == null) {
      setState(() {
        _batchStudents = [];
      });
      return;
    }

    setState(() => _loadingStudents = true);
    try {
      final batchService = ref.read(batchServiceProvider);
      final students = await batchService.getBatchStudents(_selectedBatchId!);
      setState(() {
        _batchStudents = students;
        _loadingStudents = false;
      });
    } catch (e) {
      setState(() => _loadingStudents = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to load students: ${e.toString()}');
      }
    }
  }

  Widget _buildStudentSelector() {
    if (_loadingStudents) {
      return const Center(child: ListSkeleton(itemCount: 3));
    }

    if (_batchStudents.isEmpty) {
      return const Text(
        'No students in this batch',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: DropdownButtonFormField<int>(
        initialValue: _selectedStudentId,
        decoration: const InputDecoration(
          labelText: 'Select Student',
          labelStyle: TextStyle(color: AppColors.textSecondary),
          border: InputBorder.none,
        ),
        dropdownColor: AppColors.cardBackground,
        style: const TextStyle(color: AppColors.textPrimary),
        items: _batchStudents.map((student) {
          return DropdownMenuItem<int>(
            value: student.id,
            child: Text(student.name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedStudentId = value;
          });
          _loadPerformanceHistory();
        },
      ),
    );
  }

  Widget _buildTableForm() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => setState(() => _showAddForm = false),
        ),
        title: const Text(
          'Add Performance Records',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Batch and Date Selection
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                // Batch Selector (in form)
                _buildBatchSelectorInForm(),

                const SizedBox(height: AppDimensions.spacingM),

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
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                        ),
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
              ],
            ),
          ),

          // Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: _buildPerformanceTable(),
                ),
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveBulkPerformance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingM,
                  ),
                ),
                child: _isLoading
                    ? const ListSkeleton(itemCount: 3)
                    : const Text(
                        'Save Performance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTable() {
    if (_batchStudents.isEmpty) {
      return const Center(
        child: Text(
          'No students in this batch',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Calculate minimum table width
    const studentColWidth = 120.0;
    const skillColWidth = 80.0;
    const commentsColWidth = 200.0; // Fixed width for comments
    final minTableWidth =
        studentColWidth + (skillColWidth * _skills.length) + commentsColWidth;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minTableWidth),
      child: Table(
        border: TableBorder.all(
          color: AppColors.textSecondary.withOpacity(0.2),
          width: 1,
        ),
        columnWidths: {
          0: const FixedColumnWidth(studentColWidth), // Student name
          for (int i = 1; i <= _skills.length; i++)
            i: const FixedColumnWidth(skillColWidth), // Skill columns
          _skills.length + 1: const FixedColumnWidth(
            commentsColWidth,
          ), // Comments column - fixed width
        },
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1)),
            children: [
              _buildTableHeaderCell('Student'),
              ..._skills.map(
                (skill) => _buildTableHeaderCell(skill['label'] as String),
              ),
              _buildTableHeaderCell('Comments'),
            ],
          ),
          // Data rows
          ..._batchStudents.map((student) {
            final studentData =
                _tableData[student.id] ??
                {
                  'serve': 0,
                  'smash': 0,
                  'footwork': 0,
                  'defense': 0,
                  'stamina': 0,
                  'comments': '',
                };

            // Ensure comment controller exists
            if (!_commentControllers.containsKey(student.id)) {
              _commentControllers[student.id] = TextEditingController(
                text: studentData['comments'] as String? ?? '',
              );
            }

            return TableRow(
              children: [
                _buildTableCell(
                  Text(
                    student.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ..._skills.map((skill) {
                  final key = skill['key'] as String;
                  final rating = studentData[key] as int? ?? 0;
                  return _buildRatingCell(student.id, key, rating);
                }),
                _buildCommentsCell(
                  student.id,
                  studentData['comments'] as String? ?? '',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget child) {
    return Container(padding: const EdgeInsets.all(4.0), child: child);
  }

  Widget _buildRatingCell(int studentId, String skillKey, int currentRating) {
    return _buildTableCell(
      TextField(
        controller: TextEditingController(
          text: currentRating > 0 ? currentRating.toString() : '',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[1-5]')),
          LengthLimitingTextInputFormatter(1),
        ],
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
        ),
        onChanged: (value) {
          setState(() {
            if (!_tableData.containsKey(studentId)) {
              _tableData[studentId] = {
                'serve': 0,
                'smash': 0,
                'footwork': 0,
                'defense': 0,
                'stamina': 0,
                'comments': '',
              };
            }
            _tableData[studentId]![skillKey] = value.isEmpty
                ? 0
                : int.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

  Widget _buildCommentsCell(int studentId, String currentComments) {
    // Get or create controller for this student
    if (!_commentControllers.containsKey(studentId)) {
      _commentControllers[studentId] = TextEditingController(
        text: currentComments,
      );
    }

    final controller = _commentControllers[studentId]!;

    return Container(
      padding: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(minWidth: 200, minHeight: 50),
      child: TextField(
        controller: controller,
        maxLines: 3,
        minLines: 2,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.all(8),
          filled: true,
          fillColor: AppColors.cardBackground,
          hintText: 'Add comments...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
        ),
        onChanged: (value) {
          setState(() {
            if (!_tableData.containsKey(studentId)) {
              _tableData[studentId] = {
                'serve': 0,
                'smash': 0,
                'footwork': 0,
                'defense': 0,
                'stamina': 0,
                'comments': '',
              };
            }
            _tableData[studentId]!['comments'] = value;
          });
        },
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM, yyyy').format(performance.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (performance.batchName != null)
                    Text(
                      performance.batchName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
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
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
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
          if (performance.comments != null &&
              performance.comments!.isNotEmpty) ...[
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

  Widget _buildProgressChart() {
    if (_performanceHistory.length < 2) {
      return const SizedBox.shrink();
    }

    // Sort by date
    final sortedHistory = List<Performance>.from(_performanceHistory)
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
          const Text(
            'Skill Performance Trends',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          SizedBox(
            height: 250,
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
                  // Average Line (Thick)
                  _createLineData(avgSpots, AppColors.accent, isMain: true),
                  // Skill Lines (Thin)
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
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem('Average', AppColors.accent, isMain: true),
              _buildLegendItem('Serve', Colors.blue),
              _buildLegendItem('Smash', Colors.red),
              _buildLegendItem('Footwork', Colors.green),
              _buildLegendItem('Defense', Colors.orange),
              _buildLegendItem('Stamina', Colors.purple),
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
      barWidth: isMain ? 4 : 2,
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
          width: 12,
          height: isMain ? 4 : 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
