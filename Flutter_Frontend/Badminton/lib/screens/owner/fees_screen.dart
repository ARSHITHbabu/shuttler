import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../models/fee.dart';
import '../../providers/service_providers.dart';
import '../../providers/fee_provider.dart';
import '../../widgets/forms/add_fee_dialog.dart';
import '../../widgets/forms/add_payment_dialog.dart';
import '../../models/fee_payment.dart';

/// Fees Screen - Shows paid and unpaid fees
class FeesScreen extends ConsumerStatefulWidget {
  const FeesScreen({super.key});

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> {
  String _selectedFilter = 'all'; // 'all', 'paid', 'pending', 'overdue'

  @override
  Widget build(BuildContext context) {
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
          'Fees',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: SingleChildScrollView(
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
                    label: 'Paid',
                    isSelected: _selectedFilter == 'paid',
                    onTap: () => setState(() => _selectedFilter = 'paid'),
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _FilterChip(
                    label: 'Pending',
                    isSelected: _selectedFilter == 'pending',
                    onTap: () => setState(() => _selectedFilter = 'pending'),
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _FilterChip(
                    label: 'Overdue',
                    isSelected: _selectedFilter == 'overdue',
                    onTap: () => setState(() => _selectedFilter = 'overdue'),
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),
          // Fees List
          Expanded(
            child: _buildFeesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFeeDialog(context),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Fee',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFeesList() {
    // Use provider for fee list with status filter
    String? statusFilter;
    if (_selectedFilter == 'overdue') {
      // For overdue, we'll filter after fetching
      statusFilter = null;
    } else if (_selectedFilter != 'all') {
      statusFilter = _selectedFilter;
    }

    final feesAsync = ref.watch(feeListProvider(
      status: statusFilter,
    ));

    return feesAsync.when(
      loading: () => const ListSkeleton(itemCount: 5),
      error: (error, stack) => ErrorDisplay(
        message: 'Failed to load fees: ${error.toString()}',
        onRetry: () {
          ref.invalidate(feeListProvider(status: statusFilter));
        },
      ),
      data: (allFees) {
        // Filter by overdue if needed
        final fees = _selectedFilter == 'overdue'
            ? allFees.where((fee) => fee.isOverdue).toList()
            : allFees;

        if (fees.isEmpty) {
          return const Center(
            child: Text(
              'No fees records found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(feeListProvider(status: statusFilter));
            return;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            itemCount: fees.length,
            itemBuilder: (context, index) {
              final fee = fees[index];
                      return NeumorphicContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fee.studentName ?? 'Student #${fee.studentId}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (fee.studentName == null)
                                        Text(
                                          'ID: ${fee.studentId}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
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
                            // Fee Summary: Total | Paid | Pending
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.paddingM),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total:',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '₹${fee.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppDimensions.spacingS),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Paid:',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '₹${fee.totalPaid.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppDimensions.spacingS),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Pending:',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '₹${fee.pendingAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: fee.pendingAmount > 0 ? AppColors.error : AppColors.success,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Due Date:',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _formatDate(fee.dueDate),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            if (fee.payeeStudentName != null) ...[
                              const SizedBox(height: AppDimensions.spacingS),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Payee:',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    fee.payeeStudentName!,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Payment History
                            if (fee.payments != null && fee.payments!.isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.spacingM),
                              ExpansionTile(
                                title: const Text(
                                  'Payment History',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                children: fee.payments!.map((payment) {
                                  return ListTile(
                                    title: Text(
                                      '₹${payment.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${_formatDate(payment.paidDate)}${payment.payeeDisplayName != null ? ' • ${payment.payeeDisplayName}' : ''}${payment.paymentMethod != null ? ' • ${payment.paymentMethod}' : ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18),
                                      onPressed: () => _showDeletePaymentDialog(context, fee, payment),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            // Action Buttons
                            const SizedBox(height: AppDimensions.spacingM),
                            if (fee.status != 'paid') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showAddPaymentDialog(context, fee),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add Payment'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (fee.status == 'overdue') ...[
                              const SizedBox(height: AppDimensions.spacingS),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showNotifyStudentDialog(context, fee),
                                      icon: const Icon(Icons.notifications, size: 18),
                                      label: const Text('Notify Student'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
            },
          ),
        );
      },
    );
  }

  void _showAddFeeDialog(BuildContext context) {
    // Capture ref and mounted before dialog - these are available in ConsumerState
    final widgetRef = ref;
    final isMounted = mounted;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AddFeeDialog(
        onSubmit: (feeData) async {
          try {
            // Use the fee list provider notifier to create fee
            final feeListNotifier = widgetRef.read(feeListProvider(status: null).notifier);
            await feeListNotifier.createFee(feeData);
            if (isMounted && mounted) {
              Navigator.of(dialogContext).pop();
              SuccessSnackbar.show(context, 'Fee created successfully');
            }
          } catch (e) {
            if (isMounted && mounted) {
              SuccessSnackbar.showError(context, 'Failed to create fee: ${e.toString()}');
            }
          }
        },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }


  void _showAddPaymentDialog(BuildContext context, Fee fee) {
    // Capture ref, selectedFilter, and mounted before dialog
    final widgetRef = ref;
    final currentFilter = _selectedFilter;
    final isMounted = mounted;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AddPaymentDialog(
        fee: fee,
        onSubmit: (paymentData) async {
          try {
            final feeService = widgetRef.read(feeServiceProvider);
            await feeService.createFeePayment(fee.id, paymentData);
            // Refresh fee list provider - get current filter
            String? currentStatus;
            if (currentFilter != 'all' && currentFilter != 'overdue') {
              currentStatus = currentFilter;
            }
            widgetRef.invalidate(feeListProvider(status: currentStatus));
            if (isMounted && mounted) {
              Navigator.of(dialogContext).pop();
              SuccessSnackbar.show(context, 'Payment recorded successfully');
            }
          } catch (e) {
            if (isMounted && mounted) {
              SuccessSnackbar.showError(context, 'Failed to record payment: ${e.toString()}');
            }
          }
        },
      ),
    );
  }

  void _showDeletePaymentDialog(BuildContext context, Fee fee, FeePayment payment) {
    // Capture ref, selectedFilter, and mounted before dialog
    final widgetRef = ref;
    final currentFilter = _selectedFilter;
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
          // Refresh fee list provider - get current filter
          String? currentStatus;
          if (currentFilter != 'all' && currentFilter != 'overdue') {
            currentStatus = currentFilter;
          }
          widgetRef.invalidate(feeListProvider(status: currentStatus));
          if (isMounted && mounted) {
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

  void _showNotifyStudentDialog(BuildContext context, Fee fee) {
    // Capture ref and mounted before dialog
    final widgetRef = ref;
    final isMounted = mounted;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Notify Student', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Send payment reminder to ${fee.studentName ?? 'Student #${fee.studentId}'}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final feeService = widgetRef.read(feeServiceProvider);
                await feeService.notifyStudent(fee.id);
                if (isMounted && mounted) {
                  Navigator.of(dialogContext).pop();
                  SuccessSnackbar.show(context, 'Notification sent successfully');
                }
              } catch (e) {
                if (isMounted && mounted) {
                  Navigator.of(dialogContext).pop();
                  SuccessSnackbar.showError(context, 'Failed to send notification: ${e.toString()}');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
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
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (color ?? AppColors.accent)
                : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
