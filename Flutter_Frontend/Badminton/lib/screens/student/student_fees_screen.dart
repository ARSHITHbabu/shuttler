import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/more_screen_app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fee_provider.dart';
import '../../models/fee.dart';

/// Student Fees Screen - READ-ONLY view of fee status and payment history
/// Students can view their fee records but cannot make payments
class StudentFeesScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentFeesScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends ConsumerState<StudentFeesScreen> {
  String _selectedFilter = 'all'; // 'all', 'paid', 'pending', 'overdue'

  // Calculate stats from fee list
  Map<String, dynamic> _calculateStats(List<Fee> fees) {
    double totalFees = 0;
    double paidFees = 0;
    double pendingFees = 0;
    double overdueFees = 0;
    int paidCount = 0;

    for (var fee in fees) {
      totalFees += fee.amount;

      if (fee.status == 'paid') {
        paidFees += fee.amount;
        paidCount++;
      } else {
        if (fee.dueDate.isBefore(DateTime.now())) {
          overdueFees += fee.amount;
        } else {
          pendingFees += fee.amount;
        }
      }
    }

    return {
      'total_fees': totalFees,
      'paid_fees': paidFees,
      'pending_fees': pendingFees,
      'overdue_fees': overdueFees,
      'paid_count': paidCount,
      'total_count': fees.length,
    };
  }

  List<Fee> _filterFees(List<Fee> fees) {
    if (_selectedFilter == 'all') {
      return fees;
    }

    return fees.where((fee) {
      if (_selectedFilter == 'paid') {
        return fee.status == 'paid';
      } else if (_selectedFilter == 'pending') {
        return fee.status != 'paid' && !fee.dueDate.isBefore(DateTime.now());
      } else if (_selectedFilter == 'overdue') {
        return fee.status != 'paid' && fee.dueDate.isBefore(DateTime.now());
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get user ID from auth provider
    final authStateAsync = ref.watch(authProvider);
    
    return authStateAsync.when(
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: ListSkeleton(itemCount: 5)),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ErrorDisplay(
          message: 'Failed to load user data: ${error.toString()}',
          onRetry: () => ref.invalidate(authProvider),
        ),
      ),
      data: (authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: ErrorDisplay(
              message: 'Please log in to view fee records',
              onRetry: () => ref.invalidate(authProvider),
            ),
          );
        }

        final userId = authState.userId;
        final feesAsync = ref.watch(feeByStudentProvider(userId));

        void _handleReload() {
          ref.invalidate(feeByStudentProvider(userId));
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MoreScreenAppBar(
            title: 'Fee Status',
            onReload: _handleReload,
            isDark: isDark,
            onBack: widget.onBack,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              _handleReload();
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [

                // Content
                SliverToBoxAdapter(
                  child: feesAsync.when(
                    loading: () => const SizedBox(
                      height: 400,
                      child: ListSkeleton(itemCount: 3),
                    ),
                    error: (error, stack) => ErrorDisplay(
                      message: 'Failed to load fee records: ${error.toString()}',
                      onRetry: () => ref.invalidate(feeByStudentProvider(userId)),
                    ),
                    data: (fees) {
                      if (fees.isEmpty) {
                        return EmptyState.noFees();
                      }

                      final feeStats = _calculateStats(fees);
                      final filteredFees = _filterFees(fees);

                      return Column(
                        children: [
                          // Stats Summary
                          _buildStatsSummary(isDark, feeStats),

                          const SizedBox(height: AppDimensions.spacingL),

                          // Payment Progress
                          _buildPaymentProgress(isDark, feeStats),

                          const SizedBox(height: AppDimensions.spacingL),

                          // Filter Tabs
                          _buildFilterTabs(isDark),

                          const SizedBox(height: AppDimensions.spacingM),

                          // Section Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fee Records',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${filteredFees.length} records',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppDimensions.spacingM),
                        ],
                      );
                    },
                  ),
                ),

                // Fee Records List
                feesAsync.when(
                  loading: () => const SliverToBoxAdapter(child: SizedBox()),
                  error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                  data: (fees) {
                    final filteredFees = _filterFees(fees);
                    
                    if (filteredFees.isEmpty) {
                      return SliverToBoxAdapter(
                        child: EmptyState.noFees(),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final fee = filteredFees[index];
                          return _FeeRecordCard(
                            fee: fee,
                            isDark: isDark,
                          );
                        },
                        childCount: filteredFees.length,
                      ),
                    );
                  },
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSummary(bool isDark, Map<String, dynamic> feeStats) {
    final totalFees = (feeStats['total_fees'] ?? 0.0).toDouble();
    final paidFees = (feeStats['paid_fees'] ?? 0.0).toDouble();
    final pendingFees = (feeStats['pending_fees'] ?? 0.0).toDouble();
    final overdueFees = (feeStats['overdue_fees'] ?? 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Fees',
                  value: _formatCurrency(totalFees),
                  icon: Icons.account_balance_wallet,
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _StatCard(
                  label: 'Paid',
                  value: _formatCurrency(paidFees),
                  icon: Icons.check_circle,
                  color: isDark ? AppColors.success : AppColorsLight.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Pending',
                  value: _formatCurrency(pendingFees),
                  icon: Icons.schedule,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _StatCard(
                  label: 'Overdue',
                  value: _formatCurrency(overdueFees),
                  icon: Icons.warning,
                  color: isDark ? AppColors.error : AppColorsLight.error,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProgress(bool isDark, Map<String, dynamic> feeStats) {
    final paidCount = (feeStats['paid_count'] ?? 0) as int;
    final totalCount = (feeStats['total_count'] ?? 0) as int;
    final progress = totalCount > 0 ? paidCount / totalCount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                Text(
                  '$paidCount / $totalCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.accent : AppColorsLight.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: isDark ? AppColors.background : AppColorsLight.background,
                borderRadius: BorderRadius.circular(6),
                boxShadow: NeumorphicStyles.getSmallInsetShadow(),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark ? AppColors.success : AppColorsLight.success,
                        (isDark ? AppColors.success : AppColorsLight.success).withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% payments completed',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: _selectedFilter == 'all',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'all'),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _FilterChip(
              label: 'Paid',
              isSelected: _selectedFilter == 'paid',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'paid'),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _FilterChip(
              label: 'Pending',
              isSelected: _selectedFilter == 'pending',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'pending'),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _FilterChip(
              label: 'Overdue',
              isSelected: _selectedFilter == 'overdue',
              isDark: isDark,
              onTap: () => setState(() => _selectedFilter = 'overdue'),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _buildEmptyState - using EmptyState.noFees() instead

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.accent : AppColorsLight.accent)
              : (isDark ? AppColors.cardBackground : AppColorsLight.cardBackground),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: isSelected ? null : NeumorphicStyles.getElevatedShadow(),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _FeeRecordCard extends StatelessWidget {
  final Fee fee;
  final bool isDark;

  const _FeeRecordCard({
    required this.fee,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final amount = fee.amount;
    final status = fee.status.toLowerCase();
    final dueDate = fee.dueDate;
    final payments = fee.payments;
    final paidDate = (payments != null && payments.isNotEmpty)
        ? payments.first.paidDate 
        : null;
    final month = fee.batchName ?? 'Fee';
    final paymentMethod = (payments != null && payments.isNotEmpty)
        ? payments.first.paymentMethod
        : null;

    final isPaid = status == 'paid';
    final isOverdue = !isPaid && dueDate.isBefore(DateTime.now());

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isPaid) {
      statusColor = isDark ? AppColors.success : AppColorsLight.success;
      statusText = 'Paid';
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusColor = isDark ? AppColors.error : AppColorsLight.error;
      statusText = 'Overdue';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.orange;
      statusText = 'Pending';
      statusIcon = Icons.schedule;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingS,
      ),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.accent : AppColorsLight.accent,
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Details Row
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: isDark ? AppColors.background : AppColorsLight.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                boxShadow: NeumorphicStyles.getSmallInsetShadow(),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.event,
                    label: 'Due Date',
                    value: _formatDate(dueDate),
                    isDark: isDark,
                  ),
                  if (isPaid && paidDate != null) ...[
                    const SizedBox(height: AppDimensions.spacingS),
                    _DetailRow(
                      icon: Icons.check,
                      label: 'Paid Date',
                      value: _formatDate(paidDate),
                      isDark: isDark,
                    ),
                  ],
                  if (paymentMethod != null && paymentMethod.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingS),
                    _DetailRow(
                      icon: Icons.payment,
                      label: 'Method',
                      value: paymentMethod,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
