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
// Keep this if used, otherwise remove
import '../../../providers/batch_provider.dart';
import '../../../providers/dashboard_provider.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final horizontalPadding = isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fee Records',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),
          
          // Fee List
          _buildFeeList(),
        ],
      ),
    );
  }

  Widget _buildFeeList() {
    final studentId = widget.student.id;
    final feesAsync = ref.watch(feeByStudentProvider(studentId));
    final batchesAsync = ref.watch(studentBatchesProvider(studentId));

    return feesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Failed to load fees: ${error.toString()}',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
      data: (existingFees) {
        return batchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildFeesListOnly(existingFees), // Fallback
          data: (batches) {
            // Merge existing fees with batches
            final allFees = <Fee>[];
            
            // Add existing fees
            allFees.addAll(existingFees);
            
            // Check for batches without fees
            for (final batch in batches) {
              final hasFee = existingFees.any((f) => f.batchId == batch.id);
              if (!hasFee) {
                // Parse fee amount
                double batchFeeAmount = 0;
                try {
                  final feeString = batch.fees.replaceAll(RegExp(r'[\$,\s]'), '');
                  batchFeeAmount = double.parse(feeString);
                } catch (e) {
                  batchFeeAmount = 0;
                }

                // Create virtual pending fee
                // Note: ID -1 indicates it's virtual and needs creation
                final virtualFee = Fee(
                  id: -1, 
                  studentId: studentId,
                  batchId: batch.id,
                  batchName: batch.batchName,
                  amount: batchFeeAmount,
                  totalPaid: 0,
                  pendingAmount: batchFeeAmount,
                  dueDate: DateTime.now(), // Will be set properly when created
                  status: 'pending',
                  createdAt: DateTime.now(),
                );
                allFees.add(virtualFee);
              }
            }

            if (allFees.isEmpty) {
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

            // Sort by status (pending first) then due date
            allFees.sort((a, b) {
              // Priority: Overdue > Pending > Paid
              int getScore(Fee f) {
                if (f.status == 'overdue' || f.isOverdue) return 0;
                if (f.status == 'pending') return 1;
                return 2;
              }
              
              final scoreA = getScore(a);
              final scoreB = getScore(b);
              
              if (scoreA != scoreB) return scoreA.compareTo(scoreB);
              return b.dueDate.compareTo(a.dueDate);
            });

            return Column(
              children: allFees.map((fee) => _buildFeeCard(fee)).toList(),
            );
          },
        );
      },
    );
  }

  // Fallback if batch fetching fails
  Widget _buildFeesListOnly(List<Fee> fees) {
    if (fees.isEmpty) {
      return const Center(
        child: Text(
          'No fee records found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: fees.map((fee) => _buildFeeCard(fee)).toList(),
    );
  }

  Widget _buildFeeCard(Fee fee) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingS : AppDimensions.paddingM),
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
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${fee.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(fee.status),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  fee.status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
          
          // Details
          _buildInfoRow(Icons.calendar_today, 'Due Date', DateFormat('dd MMM, yyyy').format(fee.dueDate)),
          const SizedBox(height: AppDimensions.spacingS),
          _buildInfoRow(
            Icons.check_circle,
            'Paid',
            '₹${fee.totalPaid.toStringAsFixed(2)}',
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _buildInfoRow(
            Icons.pending,
            'Pending',
            '₹${fee.pendingAmount.toStringAsFixed(2)}',
            valueColor: fee.pendingAmount > 0 ? AppColors.error : AppColors.success,
          ),
          
          // Payment History
          if (fee.payments != null && fee.payments!.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
            const Divider(color: AppColors.textSecondary),
            SizedBox(height: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
            Text(
              'Payment History',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            ...fee.payments!.map((payment) => _buildPaymentItem(fee, payment)),
          ],
          
          SizedBox(height: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
          
          // Action Buttons
          isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddPaymentDialog(fee),
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Add Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    OutlinedButton.icon(
                      onPressed: fee.id == -1 ? null : () => _editFee(fee),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.textPrimary.withOpacity(0.2), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddPaymentDialog(fee),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Add Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    OutlinedButton.icon(
                      onPressed: fee.id == -1 ? null : () => _editFee(fee),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.textPrimary.withOpacity(0.2), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingS - 2 : AppDimensions.paddingS),
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
                  '₹${payment.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('dd MMM, yyyy').format(payment.paidDate)}${payment.payeeDisplayName != null ? ' • ${payment.payeeDisplayName}' : ''}${payment.paymentMethod != null ? ' • ${payment.paymentMethod}' : ''}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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

  /// Auto-create fee if it doesn't exist (virtual fee), then return the fee
  Future<Fee> _ensureFeeExists(Fee fee) async {
    if (fee.id != -1) {
      return fee;
    }

    // Auto-create fee with batch fee amount and default due date (end of current month)
    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month + 1, 0); // Last day of current month

    final feeData = {
      'student_id': fee.studentId,
      'batch_id': fee.batchId,
      'amount': fee.amount,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'payee_student_id': fee.studentId, // Default to student themselves
    };

    final feeService = ref.read(feeServiceProvider);
    final createdFee = await feeService.createFee(feeData);
    
    // Invalidate providers to refresh the list
    ref.invalidate(feeByStudentProvider(widget.student.id));
    ref.invalidate(dashboardStatsProvider);
    
    return createdFee;
  }

  void _showAddPaymentDialog(Fee fee) async {
    final widgetRef = ref;
    final isMounted = mounted; // capture mounted state
    
    try {
      // If virtual fee, create it first
      final effectiveFee = await _ensureFeeExists(fee);
      
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => AddPaymentDialog(
          fee: effectiveFee,
          onSubmit: (paymentData) async {
            try {
              final feeService = widgetRef.read(feeServiceProvider);
              await feeService.createFeePayment(effectiveFee.id, paymentData);
              
              // Refresh fee list
              if (mounted) { // check mounted using the property directly
                // Invalidate providers to refresh the list
                 widgetRef.invalidate(feeByStudentProvider(widget.student.id));
                 widgetRef.invalidate(feeListProvider); // Refresh global list too
                 
                Navigator.of(dialogContext).pop();
                SuccessSnackbar.show(context, 'Payment recorded successfully');
              }
            } catch (e) {
              if (mounted) {
                SuccessSnackbar.showError(context, 'Failed to record payment: ${e.toString()}');
              }
              rethrow;
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to prepare fee record: ${e.toString()}');
      }
    }
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
      'Are you sure you want to delete this payment of ₹${payment.amount.toStringAsFixed(2)}?',
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
