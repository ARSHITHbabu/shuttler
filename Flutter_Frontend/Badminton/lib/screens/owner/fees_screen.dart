import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../models/fee.dart';
import '../../providers/service_providers.dart';
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
            child: FutureBuilder<List<Fee>>(
              future: _loadFees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingSpinner());
                }

                if (snapshot.hasError) {
                  return ErrorDisplay(
                    message: 'Failed to load fees',
                    onRetry: () => setState(() {}),
                  );
                }

                final fees = snapshot.data ?? [];

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
                    setState(() {});
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
            ),
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

  void _showAddFeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddFeeDialog(
        onSubmit: (feeData) async {
          try {
            final feeService = ref.read(feeServiceProvider);
            await feeService.createFee(feeData);
            if (mounted) {
              setState(() {}); // Refresh the list
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create fee: $e')),
              );
            }
            rethrow;
          }
        },
      ),
    );
  }

  Future<List<Fee>> _loadFees() async {
    try {
      final feeService = ref.read(feeServiceProvider);
      
      // Use unified endpoint with status filter
      String? statusFilter;
      if (_selectedFilter != 'all') {
        if (_selectedFilter == 'overdue') {
          // For overdue, we'll filter after fetching
          statusFilter = null;
        } else {
          statusFilter = _selectedFilter;
        }
      }
      
      List<Fee> allFees = await feeService.getFees(status: statusFilter);
      
      // Filter by overdue if needed
      if (_selectedFilter == 'overdue') {
        allFees = allFees.where((fee) => fee.isOverdue).toList();
      }
      
      return allFees;
    } catch (e) {
      // Log error for debugging instead of silently failing
      debugPrint('Error loading fees: $e');
      // Re-throw to let FutureBuilder handle it properly
      rethrow;
    }
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
    showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(
        fee: fee,
        onSubmit: (paymentData) async {
          try {
            final feeService = ref.read(feeServiceProvider);
            await feeService.createFeePayment(fee.id, paymentData);
            if (mounted) {
              Navigator.of(context).pop();
              setState(() {}); // Refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment recorded successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to record payment: $e')),
              );
            }
            rethrow;
          }
        },
      ),
    );
  }

  void _showDeletePaymentDialog(BuildContext context, Fee fee, FeePayment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Payment', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete this payment of ₹${payment.amount.toStringAsFixed(2)}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final feeService = ref.read(feeServiceProvider);
                await feeService.deleteFeePayment(fee.id, payment.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh the list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete payment: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showNotifyStudentDialog(BuildContext context, Fee fee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Notify Student', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Send payment reminder to ${fee.studentName ?? 'Student #${fee.studentId}'}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final feeService = ref.read(feeServiceProvider);
                await feeService.notifyStudent(fee.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification sent successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send notification: $e')),
                  );
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
