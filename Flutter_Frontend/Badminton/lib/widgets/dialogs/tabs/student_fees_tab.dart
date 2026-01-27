import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/success_snackbar.dart';
import '../../../widgets/common/confirmation_dialog.dart';
import '../../../widgets/forms/add_payment_dialog.dart';
import '../../../widgets/forms/edit_fee_dialog.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/fee_provider.dart';
import '../../../models/fee.dart';
import '../../../models/fee_payment.dart';
import '../../../models/student.dart';
import '../../../models/student_with_batch_fee.dart';
import 'package:intl/intl.dart';

/// Fees Tab - Shows student fees and allows managing payments
class StudentFeesTab extends ConsumerStatefulWidget {
  final Student student;

  const StudentFeesTab({
    super.key,
    required this.student,
  });

  @override
  ConsumerState<StudentFeesTab> createState() => _StudentFeesTabState();
}

class _StudentFeesTabState extends ConsumerState<StudentFeesTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Fee List
          _buildFeeList(),
        ],
      ),
    );
  }

  Widget _buildFeeList() {
    return FutureBuilder<List<Fee>>(
      future: ref.read(feeServiceProvider).getFees(studentId: widget.student.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load fees: ${snapshot.error.toString()}',
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        final fees = snapshot.data ?? [];

        if (fees.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(
                  Icons.attach_money_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                const Text(
                  'No fee records found',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort by due date descending
        fees.sort((a, b) => b.dueDate.compareTo(a.dueDate));

        return Column(
          children: fees.map((fee) => _buildFeeCard(fee)).toList(),
        );
      },
    );
  }

  Widget _buildFeeCard(Fee fee) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fee.batchName != null)
                      Text(
                        fee.batchName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${fee.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(fee.status),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  fee.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          
          // Details
          _buildInfoRow(Icons.calendar_today, 'Due Date', DateFormat('dd MMM, yyyy').format(fee.dueDate)),
          const SizedBox(height: AppDimensions.spacingS),
          _buildInfoRow(
            Icons.check_circle,
            'Paid',
            '\$${fee.totalPaid.toStringAsFixed(2)}',
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _buildInfoRow(
            Icons.pending,
            'Pending',
            '\$${fee.pendingAmount.toStringAsFixed(2)}',
            valueColor: fee.pendingAmount > 0 ? AppColors.error : AppColors.success,
          ),
          
          // Payment History
          if (fee.payments != null && fee.payments!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(color: AppColors.textSecondary),
            const SizedBox(height: AppDimensions.spacingM),
            const Text(
              'Payment History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            ...fee.payments!.map((payment) => _buildPaymentItem(fee, payment)),
          ],
          
          const SizedBox(height: AppDimensions.spacingM),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPaymentDialog(fee),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Add Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              OutlinedButton.icon(
                onPressed: () => _editFee(fee),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(Fee fee, FeePayment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('dd MMM, yyyy').format(payment.paidDate)}${payment.payeeDisplayName != null ? ' • ${payment.payeeDisplayName}' : ''}${payment.paymentMethod != null ? ' • ${payment.paymentMethod}' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
            onPressed: () => _showDeletePaymentDialog(fee, payment),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'overdue':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showAddPaymentDialog(Fee fee) {
    final widgetRef = ref;
    final isMounted = mounted;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AddPaymentDialog(
        fee: fee,
        onSubmit: (paymentData) async {
          try {
            final feeService = widgetRef.read(feeServiceProvider);
            await feeService.createFeePayment(fee.id, paymentData);
            
            // Refresh fee list
            if (isMounted && mounted) {
              setState(() {});
              Navigator.of(dialogContext).pop();
              SuccessSnackbar.show(context, 'Payment recorded successfully');
            }
          } catch (e) {
            if (isMounted && mounted) {
              SuccessSnackbar.showError(context, 'Failed to record payment: ${e.toString()}');
            }
            rethrow;
          }
        },
      ),
    );
  }

  void _editFee(Fee fee) {
    final widgetRef = ref;
    final isMounted = mounted;
    
    showDialog(
      context: context,
      builder: (dialogContext) => EditFeeDialog(
        fee: fee,
        onSubmit: (feeData) async {
          try {
            final feeListNotifier = widgetRef.read(feeListProvider(status: null).notifier);
            await feeListNotifier.updateFee(fee.id, feeData);
            
            if (isMounted && mounted) {
              setState(() {});
              Navigator.of(dialogContext).pop();
              SuccessSnackbar.show(context, 'Fee updated successfully');
            }
          } catch (e) {
            if (isMounted && mounted) {
              SuccessSnackbar.showError(context, 'Failed to update fee: ${e.toString()}');
            }
            rethrow;
          }
        },
      ),
    );
  }

  void _showDeletePaymentDialog(Fee fee, FeePayment payment) {
    final widgetRef = ref;
    final isMounted = mounted;
    
    ConfirmationDialog.show(
      context,
      'Delete Payment',
      'Are you sure you want to delete this payment of \$${payment.amount.toStringAsFixed(2)}?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_outline,
      onConfirm: () async {
        try {
          final feeService = widgetRef.read(feeServiceProvider);
          await feeService.deleteFeePayment(fee.id, payment.id);
          
          if (isMounted && mounted) {
            setState(() {});
            SuccessSnackbar.show(context, 'Payment deleted successfully');
          }
        } catch (e) {
          if (isMounted && mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete payment: ${e.toString()}');
          }
        }
      },
    );
  }
}
