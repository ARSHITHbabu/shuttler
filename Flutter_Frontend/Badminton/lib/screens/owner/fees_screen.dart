import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../models/fee.dart';

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
                                Text(
                                  'Student ID: ${fee.studentId}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Amount:',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '₹${fee.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
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
                            if (fee.paidDate != null) ...[
                              const SizedBox(height: AppDimensions.spacingS),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Paid Date:',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(fee.paidDate!),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
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
    );
  }

  Future<List<Fee>> _loadFees() async {
    try {
      // Get fees for all students (we'll need to fetch by student or batch)
      // For now, return empty list as backend doesn't have "get all fees" endpoint
      // TODO: Implement proper fee fetching logic
      return [];
    } catch (e) {
      return [];
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
