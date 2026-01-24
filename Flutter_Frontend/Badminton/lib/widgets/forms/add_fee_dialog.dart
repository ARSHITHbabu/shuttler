import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/service_providers.dart';
import '../../models/student.dart';
import '../../models/batch.dart';
import 'package:intl/intl.dart';

/// Dialog for creating a new fee record
/// Flow: Batch -> Student (filtered) -> Payee (from batch) -> Total Fee (auto-filled from batch) -> Due Date
class AddFeeDialog extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>)? onSubmit;
  final int? initialBatchId;
  final int? initialStudentId;
  final double? initialFeeAmount;

  const AddFeeDialog({
    super.key,
    this.onSubmit,
    this.initialBatchId,
    this.initialStudentId,
    this.initialFeeAmount,
  });

  @override
  ConsumerState<AddFeeDialog> createState() => _AddFeeDialogState();
}

class _AddFeeDialogState extends ConsumerState<AddFeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _totalFeeController = TextEditingController();
  int? _selectedBatchId;
  Batch? _selectedBatch;
  int? _selectedStudentId;
  Student? _selectedStudent;
  int? _selectedPayeeId;
  Student? _selectedPayee;
  DateTime _dueDate = DateTime.now();
  bool _isLoading = false;
  List<Batch> _batches = [];
  List<Student> _batchStudents = []; // Students in selected batch
  bool _loadingBatches = true;
  bool _loadingStudents = false;

  @override
  void initState() {
    super.initState();
    // Set initial fee amount if provided
    if (widget.initialFeeAmount != null) {
      _totalFeeController.text = widget.initialFeeAmount!.toStringAsFixed(0);
    }
    _loadBatches();
  }

  @override
  void dispose() {
    _totalFeeController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final batches = await batchService.getBatches();
      setState(() {
        _batches = batches;
        _loadingBatches = false;
      });
      
      // If initial batch ID is provided, select it and load students
      if (widget.initialBatchId != null) {
        final initialBatch = batches.firstWhere(
          (b) => b.id == widget.initialBatchId,
          orElse: () => batches.first,
        );
        if (initialBatch != null) {
          _selectedBatchId = initialBatch.id;
          _selectedBatch = initialBatch;
          // Auto-fill fee amount from batch if not already set
          if (widget.initialFeeAmount == null) {
            try {
              final feeString = initialBatch.fees.replaceAll(RegExp(r'[₹,\s]'), '');
              final batchFee = double.parse(feeString);
              _totalFeeController.text = batchFee.toStringAsFixed(0);
            } catch (e) {
              // If parsing fails, keep current value or use 0
            }
          }
          await _loadBatchStudents(initialBatch.id);
        }
      }
    } catch (e) {
      setState(() {
        _loadingBatches = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load batches: $e')),
        );
      }
    }
  }

  Future<void> _loadBatchStudents(int batchId) async {
    setState(() {
      _loadingStudents = true;
      _batchStudents = [];
      // Don't reset selected student if it's the initial one
      if (widget.initialStudentId == null) {
        _selectedStudentId = null;
        _selectedStudent = null;
      }
      _selectedPayeeId = null;
      _selectedPayee = null;
    });

    try {
      final batchService = ref.read(batchServiceProvider);
      final students = await batchService.getBatchStudents(batchId);
      setState(() {
        _batchStudents = students;
        _loadingStudents = false;
        
        // Auto-select initial student if provided
        if (widget.initialStudentId != null) {
          try {
            final initialStudent = students.firstWhere(
              (s) => s.id == widget.initialStudentId,
            );
            _selectedStudentId = initialStudent.id;
            _selectedStudent = initialStudent;
            // Auto-select student as payee too
            _selectedPayeeId = initialStudent.id;
            _selectedPayee = initialStudent;
          } catch (e) {
            // Student not found in batch, ignore
          }
        }
      });
    } catch (e) {
      setState(() {
        _loadingStudents = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load students: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatchId == null || _selectedStudentId == null || _selectedPayeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select batch, student, and payee')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final feeData = {
        'student_id': _selectedStudentId,
        'batch_id': _selectedBatchId,
        'amount': double.parse(_totalFeeController.text.trim()),
        'due_date': _dueDate.toIso8601String().split('T')[0],
        'payee_student_id': _selectedPayeeId,
        // Status will be calculated automatically by backend
      };

      if (widget.onSubmit != null) {
        await widget.onSubmit!(feeData);
      }

      // Only close dialog if onSubmit succeeds (doesn't throw)
      if (mounted) {
        Navigator.of(context).pop();
        // Note: Success message is handled by the onSubmit callback
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Don't close dialog on error - let user see the error and retry
      // Error message is handled by the onSubmit callback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Fee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                // Step 1: Batch Selection
                if (_loadingBatches)
                  const LoadingSpinner()
                else
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedBatchId,
                      decoration: const InputDecoration(
                        labelText: '1. Select Batch',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                      ),
                      dropdownColor: AppColors.cardBackground,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: _batches.map((batch) {
                        return DropdownMenuItem<int>(
                          value: batch.id,
                          child: Text(batch.batchName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBatchId = value;
                          _selectedBatch = _batches.firstWhere((b) => b.id == value);
                          // Auto-fill fee amount from batch
                          try {
                            final feeString = _selectedBatch!.fees.replaceAll(RegExp(r'[₹,\s]'), '');
                            final batchFee = double.parse(feeString);
                            _totalFeeController.text = batchFee.toStringAsFixed(0);
                          } catch (e) {
                            // If parsing fails, keep current value
                          }
                        });
                        _loadBatchStudents(value!);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a batch';
                        }
                        return null;
                      },
                    ),
                  ),
                const SizedBox(height: AppDimensions.spacingM),
                // Step 2: Student Selection (filtered by batch)
                if (_selectedBatchId != null)
                  if (_loadingStudents)
                    const LoadingSpinner()
                  else
                    NeumorphicContainer(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedStudentId,
                        decoration: const InputDecoration(
                          labelText: '2. Select Student',
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
                            _selectedStudent = _batchStudents.firstWhere((s) => s.id == value);
                            // Reset payee if student changes
                            if (_selectedPayeeId == value) {
                              _selectedPayeeId = null;
                              _selectedPayee = null;
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a student';
                          }
                          return null;
                        },
                      ),
                    ),
                const SizedBox(height: AppDimensions.spacingM),
                // Step 3: Payee Selection (students from batch)
                if (_selectedBatchId != null && _batchStudents.isNotEmpty)
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedPayeeId,
                      decoration: const InputDecoration(
                        labelText: '3. Select Payee (Student from Batch)',
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
                          _selectedPayeeId = value;
                          _selectedPayee = _batchStudents.firstWhere((s) => s.id == value);
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a payee';
                        }
                        return null;
                      },
                    ),
                  ),
                const SizedBox(height: AppDimensions.spacingM),
                // Step 4: Total Fee (auto-filled from batch, but editable)
                if (_selectedBatch != null)
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '4. Total Fee (₹)',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              child: const Text(
                                'Auto-filled from batch',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        CustomTextField(
                          controller: _totalFeeController,
                          label: 'Fee Amount',
                          hint: 'Enter total fee amount',
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter total fee amount';
                            }
                            final amount = double.tryParse(value.trim());
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  )
                else
                  CustomTextField(
                    controller: _totalFeeController,
                    label: '4. Total Fee (₹)',
                    hint: 'Enter total fee amount',
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter total fee amount';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: AppDimensions.spacingM),
                // Step 5: Due Date
                NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _dueDate = date);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.spacingM),
                        Text(
                          '5. Due Date: ${DateFormat('dd MMM, yyyy').format(_dueDate)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                // Info: Status will be calculated automatically
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Text(
                          'Status will be calculated automatically based on payments',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Create Fee'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
