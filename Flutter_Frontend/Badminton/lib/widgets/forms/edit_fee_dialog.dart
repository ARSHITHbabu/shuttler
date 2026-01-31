import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/service_providers.dart';
import '../../models/fee.dart';
import '../../models/student.dart';
import '../../models/batch.dart';
import 'package:intl/intl.dart';

/// Dialog for editing an existing fee record
class EditFeeDialog extends ConsumerStatefulWidget {
  final Fee fee;
  final Function(Map<String, dynamic>)? onSubmit;

  const EditFeeDialog({
    super.key,
    required this.fee,
    this.onSubmit,
  });

  @override
  ConsumerState<EditFeeDialog> createState() => _EditFeeDialogState();
}

class _EditFeeDialogState extends ConsumerState<EditFeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _totalFeeController = TextEditingController();
  int? _selectedPayeeId;
  Student? _selectedPayee;
  DateTime _dueDate = DateTime.now();
  bool _isLoading = false;
  List<Student> _batchStudents = [];
  bool _loadingStudents = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing fee data
    _totalFeeController.text = widget.fee.amount.toStringAsFixed(0);
    _dueDate = widget.fee.dueDate;
    _selectedPayeeId = widget.fee.payeeStudentId;
    _loadBatchStudents();
  }

  @override
  void dispose() {
    _totalFeeController.dispose();
    super.dispose();
  }

  Future<void> _loadBatchStudents() async {
    setState(() {
      _loadingStudents = true;
    });

    try {
      final batchService = ref.read(batchServiceProvider);
      final students = await batchService.getBatchStudents(widget.fee.batchId);
      setState(() {
        _batchStudents = students;
        _loadingStudents = false;
        
        // Set selected payee if it exists
        if (_selectedPayeeId != null) {
          try {
            final payee = students.firstWhere(
              (s) => s.id == _selectedPayeeId,
            );
            _selectedPayee = payee;
          } catch (e) {
            // Payee not found in batch, reset to null
            _selectedPayeeId = null;
            _selectedPayee = null;
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
    if (_selectedPayeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payee')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final feeData = {
        'amount': double.parse(_totalFeeController.text.trim()),
        'due_date': _dueDate.toIso8601String().split('T')[0],
        'payee_student_id': _selectedPayeeId,
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
                  'Edit Fee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                // Student Info (read-only)
                NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student: ${widget.fee.studentName ?? 'Student #${widget.fee.studentId}'}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        'Batch: ${widget.fee.batchName ?? 'Batch #${widget.fee.batchId}'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                // Fee Amount
                CustomTextField(
                  controller: _totalFeeController,
                  label: 'Fee Amount (\$)',
                  hint: 'Enter fee amount',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter fee amount';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                // Payee Selection
                if (_loadingStudents)
                  const LoadingSpinner()
                else
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: DropdownButtonFormField<int>(
                      value: _selectedPayeeId,
                      decoration: const InputDecoration(
                        labelText: 'Payee (Student from Batch)',
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
                // Due Date
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
                          'Due Date: ${DateFormat('dd MMM, yyyy').format(_dueDate)}',
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
                            : const Text('Update Fee'),
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
