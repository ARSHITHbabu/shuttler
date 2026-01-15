import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/service_providers.dart';

/// Student Fees Screen - READ-ONLY view of fee status and payment history
/// Students can view their fee records but cannot make payments
class StudentFeesScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentFeesScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends ConsumerState<StudentFeesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _feeRecords = [];
  Map<String, dynamic> _feeStats = {};
  String? _error;
  String _selectedFilter = 'all'; // 'all', 'paid', 'pending', 'overdue'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final storageService = ref.read(storageServiceProvider);
      final apiService = ref.read(apiServiceProvider);
      final userId = storageService.getUserId();

      if (userId == null) {
        throw Exception('User not logged in');
      }

      try {
        final response = await apiService.get('/api/students/$userId/fees');
        if (response.statusCode == 200) {
          _feeRecords = List<Map<String, dynamic>>.from(response.data['records'] ?? []);
          _calculateStats();
        }
      } catch (e) {
        // Endpoint may not exist yet - use empty data
        _feeRecords = [];
        _feeStats = {
          'total_fees': 0.0,
          'paid_fees': 0.0,
          'pending_fees': 0.0,
          'overdue_fees': 0.0,
          'paid_count': 0,
          'total_count': 0,
        };
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _calculateStats() {
    double totalFees = 0;
    double paidFees = 0;
    double pendingFees = 0;
    double overdueFees = 0;
    int paidCount = 0;

    for (var fee in _feeRecords) {
      final amount = (fee['amount'] ?? 0).toDouble();
      final status = fee['status']?.toString().toLowerCase() ?? 'pending';
      final dueDate = DateTime.tryParse(fee['due_date']?.toString() ?? '');

      totalFees += amount;

      if (status == 'paid') {
        paidFees += amount;
        paidCount++;
      } else {
        if (dueDate != null && dueDate.isBefore(DateTime.now())) {
          overdueFees += amount;
        } else {
          pendingFees += amount;
        }
      }
    }

    _feeStats = {
      'total_fees': totalFees,
      'paid_fees': paidFees,
      'pending_fees': pendingFees,
      'overdue_fees': overdueFees,
      'paid_count': paidCount,
      'total_count': _feeRecords.length,
    };
  }

  List<Map<String, dynamic>> get _filteredRecords {
    if (_selectedFilter == 'all') {
      return _feeRecords;
    }

    return _feeRecords.where((fee) {
      final status = fee['status']?.toString().toLowerCase() ?? 'pending';
      final dueDate = DateTime.tryParse(fee['due_date']?.toString() ?? '');

      if (_selectedFilter == 'paid') {
        return status == 'paid';
      } else if (_selectedFilter == 'pending') {
        return status != 'paid' && (dueDate == null || !dueDate.isBefore(DateTime.now()));
      } else if (_selectedFilter == 'overdue') {
        return status != 'paid' && dueDate != null && dueDate.isBefore(DateTime.now());
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: widget.onBack != null
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                      onPressed: widget.onBack,
                    )
                  : null,
              title: Text(
                'Fee Status',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),

            // Content
            SliverToBoxAdapter(
              child: _isLoading
                  ? const SizedBox(
                      height: 400,
                      child: Center(child: LoadingSpinner()),
                    )
                  : _error != null
                      ? _buildErrorWidget(isDark)
                      : Column(
                          children: [
                            // Stats Summary
                            _buildStatsSummary(isDark),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Payment Progress
                            _buildPaymentProgress(isDark),

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
                                    '${_filteredRecords.length} records',
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
                        ),
            ),

            // Fee Records List
            if (!_isLoading && _error == null)
              _filteredRecords.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState(isDark))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final fee = _filteredRecords[index];
                          return _FeeRecordCard(
                            fee: fee,
                            isDark: isDark,
                          );
                        },
                        childCount: _filteredRecords.length,
                      ),
                    ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDark ? AppColors.error : AppColorsLight.error,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            _error!,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(bool isDark) {
    final totalFees = (_feeStats['total_fees'] ?? 0.0).toDouble();
    final paidFees = (_feeStats['paid_fees'] ?? 0.0).toDouble();
    final pendingFees = (_feeStats['pending_fees'] ?? 0.0).toDouble();
    final overdueFees = (_feeStats['overdue_fees'] ?? 0.0).toDouble();

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

  Widget _buildPaymentProgress(bool isDark) {
    final paidCount = (_feeStats['paid_count'] ?? 0) as int;
    final totalCount = (_feeStats['total_count'] ?? 0) as int;
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

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      child: Column(
        children: [
          Icon(
            Icons.payments_outlined,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            _selectedFilter == 'all'
                ? 'No fee records found'
                : 'No $_selectedFilter fees',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Your fee records will appear here once added by the academy',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\u20B9${amount.toStringAsFixed(0)}';
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
  final Map<String, dynamic> fee;
  final bool isDark;

  const _FeeRecordCard({
    required this.fee,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final amount = (fee['amount'] ?? 0).toDouble();
    final status = fee['status']?.toString().toLowerCase() ?? 'pending';
    final dueDate = DateTime.tryParse(fee['due_date']?.toString() ?? '');
    final paidDate = DateTime.tryParse(fee['paid_date']?.toString() ?? '');
    final month = fee['month']?.toString() ?? fee['description']?.toString() ?? 'Fee';
    final paymentMethod = fee['payment_method']?.toString() ?? '';

    final isPaid = status == 'paid';
    final isOverdue = !isPaid && dueDate != null && dueDate.isBefore(DateTime.now());

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
                        '\u20B9${amount.toStringAsFixed(0)}',
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
                    value: dueDate != null ? _formatDate(dueDate) : 'Not set',
                    isDark: isDark,
                  ),
                  if (isPaid) ...[
                    const SizedBox(height: AppDimensions.spacingS),
                    _DetailRow(
                      icon: Icons.check,
                      label: 'Paid Date',
                      value: paidDate != null ? _formatDate(paidDate) : 'N/A',
                      isDark: isDark,
                    ),
                  ],
                  if (paymentMethod.isNotEmpty) ...[
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
