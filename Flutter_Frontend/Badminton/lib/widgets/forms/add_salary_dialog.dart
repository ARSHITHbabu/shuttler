import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/custom_text_field.dart';
import 'package:intl/intl.dart';

class AddSalaryDialog extends StatefulWidget {
  final int coachId;
  final String coachName;
  final String month; // "YYYY-MM"
  final double? initialAmount;
  final Function(Map<String, dynamic>) onSubmit;

  const AddSalaryDialog({
    super.key,
    required this.coachId,
    required this.coachName,
    required this.month,
    this.initialAmount,
    required this.onSubmit,
  });

  @override
  State<AddSalaryDialog> createState() => _AddSalaryDialogState();
}

class _AddSalaryDialogState extends State<AddSalaryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _remarksController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount?.toStringAsFixed(2) ?? '',
    );
    
    // Parse the month (YYYY-MM) to get the year and month
    final parts = widget.month.split('-');
    if (parts.length == 2) {
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      // Get the last day of that month
      final lastDay = DateTime(year, month + 1, 0);
      
      // If the last day is in the future relative to today, maybe use today?
      // But the user said "at all times" it should be paid on the last day.
      _selectedDate = lastDay;
    } else {
      _selectedDate = DateTime.now();
    }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final dialogPadding = isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: isSmallScreen ? screenWidth - 32 : 500,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(dialogPadding),
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
                    fontSize: isSmallScreen ? 18 : 22,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  'For Coach: ${widget.coachName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.initialAmount != null && widget.initialAmount! > 0) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    'Suggested: \$${widget.initialAmount!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: isSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
                
                // Amount Field
                CustomTextField(
                  controller: _amountController,
                  label: 'Amount (\$)',
                  hint: 'Enter amount',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? AppDimensions.paddingS : AppDimensions.paddingM,
                      vertical: isSmallScreen ? AppDimensions.paddingS : AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.spacingM),
                        Flexible(
                          child: Text(
                            DateFormat('dd MMM, yyyy').format(_selectedDate),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
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
                SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                      ),
                      child: _isSubmitting 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          )
                        : Text(
                            'Save Record',
                            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
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
