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
import 'package:intl/intl.dart';

/// Dialog for adding a payment to an existing fee
class AddPaymentDialog extends ConsumerStatefulWidget {
  final Fee fee;
  final Function(Map<String, dynamic>)? onSubmit;

  const AddPaymentDialog({
    super.key,
    required this.fee,
    this.onSubmit,
  });

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _selectedPayeeId;
  Student? _selectedPayee;
  DateTime _paidDate = DateTime.now();
  String _selectedPaymentMethod = 'cash';
  bool _isLoading = false;
  List<Student> _batchStudents = [];
  bool _loadingStudents = true;

  @override
  void initState() {
    super.initState();
    _loadBatchStudents();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBatchStudents() async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final students = await batchService.getBatchStudents(widget.fee.batchId);
      setState(() {
        _batchStudents = students;
        _loadingStudents = false;
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

    final paymentAmount = double.parse(_amountController.text.trim());
    if (paymentAmount > widget.fee.pendingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment amount (₹${paymentAmount.toStringAsFixed(2)}) exceeds pending amount (₹${widget.fee.pendingAmount.toStringAsFixed(2)})')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentData = {
        'amount': paymentAmount,
        'paid_date': _paidDate.toIso8601String().split('T')[0],
        'payee_student_id': _selectedPayeeId,
        'payment_method': _selectedPaymentMethod,
      };

      if (widget.onSubmit != null) {
        await widget.onSubmit!(paymentData);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record payment: $e')),
        );
      }
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
                  'Add Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                // Fee Info
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student: ${widget.fee.studentName ?? 'Student #${widget.fee.studentId}'}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        'Total: ₹${widget.fee.amount.toStringAsFixed(2)} | Paid: ₹${widget.fee.totalPaid.toStringAsFixed(2)} | Pending: ₹${widget.fee.pendingAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                // Payment Amount
                CustomTextField(
                  controller: _amountController,
                  label: 'Payment Amount (₹)',
                  hint: 'Enter payment amount',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter payment amount';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount > widget.fee.pendingAmount) {
                      return 'Amount exceeds pending amount (₹${widget.fee.pendingAmount.toStringAsFixed(2)})';
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
                // Payment Method
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Wrap(
                  spacing: AppDimensions.spacingS,
                  runSpacing: AppDimensions.spacingS,
                  children: [
                    _PaymentMethodChip(
                      label: 'Cash',
                      value: 'cash',
                      selected: _selectedPaymentMethod,
                      onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
                    ),
                    _PaymentMethodChip(
                      label: 'Card',
                      value: 'card',
                      selected: _selectedPaymentMethod,
                      onTap: () => setState(() => _selectedPaymentMethod = 'card'),
                    ),
                    _PaymentMethodChip(
                      label: 'UPI',
                      value: 'upi',
                      selected: _selectedPaymentMethod,
                      onTap: () => setState(() => _selectedPaymentMethod = 'upi'),
                    ),
                    _PaymentMethodChip(
                      label: 'Bank Transfer',
                      value: 'bank_transfer',
                      selected: _selectedPaymentMethod,
                      onTap: () => setState(() => _selectedPaymentMethod = 'bank_transfer'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingM),
                // Payment Date
                NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _paidDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _paidDate = date);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.spacingM),
                        Text(
                          'Date of Payment: ${DateFormat('dd MMM, yyyy').format(_paidDate)}',
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
                            : const Text('Add Payment'),
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

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
