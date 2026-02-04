import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/custom_text_field.dart';
import 'package:intl/intl.dart';

class AddSalaryDialog extends StatefulWidget {
  final int coachId;
  final String coachName;
  final String month; // "YYYY-MM"
  final Function(Map<String, dynamic>) onSubmit;

  const AddSalaryDialog({
    super.key,
    required this.coachId,
    required this.coachName,
    required this.month,
    required this.onSubmit,
  });

  @override
  State<AddSalaryDialog> createState() => _AddSalaryDialogState();
}

class _AddSalaryDialogState extends State<AddSalaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default date to today, but constrained to the selected month?
    // Actually, payment date can be any date, but "month" field handles the accounting period.
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {
        final amount = double.parse(_amountController.text);
        
        final data = {
          'coach_id': widget.coachId,
          'amount': amount,
          'payment_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'month': widget.month,
          'remarks': _remarksController.text.isEmpty ? null : _remarksController.text,
        };

        await widget.onSubmit(data);
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Salary Payment',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                'For Coach: ${widget.coachName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              
              // Amount Field
              CustomTextField(
                controller: _amountController,
                label: 'Amount (₹)',
                hint: 'Enter amount',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingM),
              
              // Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingM,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        DateFormat('dd MMM, yyyy').format(_selectedDate),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              
              // Remarks
              CustomTextField(
                controller: _remarksController,
                label: 'Remarks (Optional)',
                hint: 'Add any notes',
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.spacingL),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text('Save Record'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
