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
import '../../models/student.dart';
import '../../providers/service_providers.dart';
import '../../providers/fee_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/forms/add_fee_dialog.dart';
import '../../widgets/forms/add_payment_dialog.dart';
import '../../models/fee_payment.dart';
import 'student_profile_screen.dart';

/// Fees Screen - Shows paid and unpaid fees with overview and deep view
class FeesScreen extends ConsumerStatefulWidget {
  final int? selectedStudentId;
  final String? selectedStudentName;

  const FeesScreen({
    super.key,
    this.selectedStudentId,
    this.selectedStudentName,
  });

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> {
  String _selectedFilter = 'all'; // 'all', 'paid', 'pending', 'overdue'
  Fee? _selectedFee; // For deep view
  final Set<int> _expandedBatches = {}; // Track expanded batches
  bool _hasAutoExpanded = false; // Track if auto-expand has already run

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we can pop (i.e., if screen was pushed separately)
    final canPop = Navigator.canPop(context);
    
    // If we have a selected fee, show deep view
    if (_selectedFee != null) {
      return _buildDeepView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: canPop
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              automaticallyImplyLeading: false,
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              String? statusFilter;
              if (_selectedFilter == 'overdue') {
                statusFilter = null;
              } else if (_selectedFilter != 'all') {
                statusFilter = _selectedFilter;
              }
              ref.invalidate(feeListProvider(status: statusFilter));
            },
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Fees',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      
                      // Stats Overview
                      _buildStatsOverview(),
                      const SizedBox(height: AppDimensions.spacingL),
                      
                      // Filter Chips
                      SingleChildScrollView(
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
                      const SizedBox(height: AppDimensions.spacingL),
                      
                      // Fees List (Overview with batch grouping)
                      _buildFeesOverview(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

  Widget _buildStatsOverview() {
    return Consumer(
      builder: (context, ref, child) {
        final feesAsync = ref.watch(feeListProvider(status: null));
        
        return feesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (allFees) {
            double pending = 0;
            double paid = 0;
            double overdue = 0;
            
            for (final fee in allFees) {
              final pendingAmount = fee.pendingAmount;
              if (fee.status == 'paid') {
                paid += fee.totalPaid;
              } else if (fee.isOverdue) {
                overdue += pendingAmount;
              } else {
                pending += pendingAmount;
              }
            }
            
            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.schedule,
                    value: '₹${pending.toStringAsFixed(0)}',
                    label: 'Pending',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    value: '₹${paid.toStringAsFixed(0)}',
                    label: 'Paid',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: _StatCard(
                    icon: Icons.warning,
                    value: '₹${overdue.toStringAsFixed(0)}',
                    label: 'Overdue',
                    color: AppColors.error,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFeesOverview() {
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
        // Auto-select student fee when navigating from student detail view
        if ((widget.selectedStudentId != null || widget.selectedStudentName != null) && 
            _selectedFee == null && 
            allFees.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Fee? studentFee;
            if (widget.selectedStudentId != null) {
              studentFee = allFees.firstWhere(
                (f) => f.studentId == widget.selectedStudentId,
                orElse: () => allFees.first,
              );
            } else if (widget.selectedStudentName != null) {
              studentFee = allFees.firstWhere(
                (f) => f.studentName == widget.selectedStudentName,
                orElse: () => allFees.first,
              );
            }
            
            if (studentFee != null && mounted) {
              setState(() {
                _selectedFee = studentFee;
                _expandedBatches.add(studentFee!.batchId);
              });
            }
          });
        }
        
        // Filter by overdue if needed
        final fees = _selectedFilter == 'overdue'
            ? allFees.where((fee) => fee.isOverdue).toList()
            : allFees;

        if (fees.isEmpty) {
          return EmptyState.noFees();
        }

        // Group fees by batch
        final Map<int, List<Fee>> batchGroups = {};
        for (final fee in fees) {
          if (!batchGroups.containsKey(fee.batchId)) {
            batchGroups[fee.batchId] = [];
          }
          batchGroups[fee.batchId]!.add(fee);
        }
        
        // Auto-expand first batch ONLY if we haven't done it yet and no batches are expanded
        if (!_hasAutoExpanded && _expandedBatches.isEmpty && batchGroups.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _expandedBatches.add(batchGroups.keys.first);
                _hasAutoExpanded = true; // Mark as done so it doesn't run again
              });
            }
          });
        }

        // Sort batches by name
        final sortedBatches = batchGroups.entries.toList()
          ..sort((a, b) {
            final nameA = a.value.first.batchName ?? 'Batch ${a.key}';
            final nameB = b.value.first.batchName ?? 'Batch ${b.key}';
            return nameA.compareTo(nameB);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedBatches.map((batchEntry) {
            final batchId = batchEntry.key;
            final batchFees = batchEntry.value;
            final batchName = batchFees.first.batchName ?? 'Batch $batchId';
            final isExpanded = _expandedBatches.contains(batchId);
            
            // Calculate batch stats
            double batchPending = 0;
            double batchPaid = 0;
            double batchOverdue = 0;
            
            for (final fee in batchFees) {
              final pendingAmount = fee.pendingAmount;
              if (fee.status == 'paid') {
                batchPaid += fee.totalPaid;
              } else if (fee.isOverdue) {
                batchOverdue += pendingAmount;
              } else {
                batchPending += pendingAmount;
              }
            }

            return NeumorphicContainer(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              child: Column(
                children: [
                  // Batch Header
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedBatches.remove(batchId);
                        } else {
                          _expandedBatches.add(batchId);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  batchName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: AppDimensions.spacingM,
                                  children: [
                                    if (batchPending > 0)
                                      Text(
                                        '₹${batchPending.toStringAsFixed(0)} pending',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    if (batchPaid > 0)
                                      Text(
                                        '₹${batchPaid.toStringAsFixed(0)} paid',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    if (batchOverdue > 0)
                                      Text(
                                        '₹${batchOverdue.toStringAsFixed(0)} overdue',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.error,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingS,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: Text(
                              '${batchFees.length} student${batchFees.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Students List
                  if (isExpanded)
                    ...batchFees.map((fee) => _buildFeeCard(fee)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFeeCard(Fee fee) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppDimensions.paddingM,
        right: AppDimensions.paddingM,
        bottom: AppDimensions.spacingS,
      ),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedFee = fee;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToStudentProfile(fee.studentId),
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
              const SizedBox(height: AppDimensions.spacingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due: ${_formatDate(fee.dueDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₹${fee.pendingAmount.toStringAsFixed(0)} pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: fee.pendingAmount > 0 ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeepView() {
    final fee = _selectedFee!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            setState(() {
              _selectedFee = null;
            });
          },
        ),
        title: const Text(
          'Fee Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Card
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _navigateToStudentProfile(fee.studentId),
                    child: Text(
                      fee.studentName ?? 'Student #${fee.studentId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  if (fee.batchName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Batch: ${fee.batchName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacingM),
            
            // Amount Summary
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${fee.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.textSecondary, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Paid Amount',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${fee.totalPaid.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.textSecondary, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining Balance',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${fee.pendingAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: fee.pendingAmount > 0 ? AppColors.error : AppColors.success,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacingM),
            
            // Status and Due Date
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
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
                        'Due Date',
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
                ],
              ),
            ),
            
            if (fee.payeeStudentName != null) ...[
              const SizedBox(height: AppDimensions.spacingM),
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payee',
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
              ),
            ],
            
            // Payment History
            if (fee.payments != null && fee.payments!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingM),
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    ...fee.payments!.map((payment) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                        padding: const EdgeInsets.all(AppDimensions.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
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
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatDate(payment.paidDate)}${payment.payeeDisplayName != null ? ' • ${payment.payeeDisplayName}' : ''}${payment.paymentMethod != null ? ' • ${payment.paymentMethod}' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: AppColors.error,
                              onPressed: () => _showDeletePaymentDialog(context, fee, payment),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            
            // Action Buttons
            const SizedBox(height: AppDimensions.spacingL),
            if (fee.status != 'paid') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPaymentDialog(context, fee),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
                  ),
                ),
              ),
            ],
            if (fee.status == 'overdue') ...[
              const SizedBox(height: AppDimensions.spacingS),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showNotifyStudentDialog(context, fee),
                  icon: const Icon(Icons.notifications, size: 20),
                  label: const Text('Notify Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _navigateToStudentProfile(fee.studentId),
                icon: const Icon(Icons.person, size: 20),
                label: const Text('View Student Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToStudentProfile(int studentId) async {
    try {
      final studentAsync = await ref.read(studentByIdProvider(studentId).future);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentProfileScreen(student: studentAsync),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(
          context,
          'Failed to load student: ${e.toString()}',
        );
      }
    }
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
