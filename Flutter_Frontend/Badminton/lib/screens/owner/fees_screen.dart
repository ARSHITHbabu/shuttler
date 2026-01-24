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
import '../../models/student_with_batch_fee.dart';
import '../../providers/service_providers.dart';
import '../../providers/fee_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/forms/add_payment_dialog.dart';
import '../../widgets/forms/edit_fee_dialog.dart';
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
                // Invalidate both providers to refresh data
                ref.invalidate(studentsWithBatchFeesProvider);
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
    );
  }

  Widget _buildStatsOverview() {
    return Consumer(
      builder: (context, ref, child) {
        final studentsWithFeesAsync = ref.watch(studentsWithBatchFeesProvider);
        
        return studentsWithFeesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (batchGroups) {
            double pending = 0;
            double paid = 0;
            double overdue = 0;
            
            // Calculate stats from all students with batch fees
            for (final batchEntry in batchGroups.values) {
              for (final studentFee in batchEntry) {
                if (studentFee.existingFee != null) {
                  final fee = studentFee.existingFee!;
                  final pendingAmount = fee.pendingAmount;
                  if (fee.status == 'paid') {
                    paid += fee.totalPaid;
                  } else if (fee.isOverdue) {
                    overdue += pendingAmount;
                  } else {
                    pending += pendingAmount;
                  }
                } else {
                  // Fee not created yet, use batch fee amount as pending
                  pending += studentFee.batchFeeAmount;
                }
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
    // Use new provider that gets all students with batch enrollments
    final studentsWithFeesAsync = ref.watch(studentsWithBatchFeesProvider);

    return studentsWithFeesAsync.when(
      loading: () => const ListSkeleton(itemCount: 5),
      error: (error, stack) => ErrorDisplay(
        message: 'Failed to load fees: ${error.toString()}',
        onRetry: () {
          ref.invalidate(studentsWithBatchFeesProvider);
        },
      ),
      data: (batchGroups) {
        // Auto-select student fee when navigating from student detail view
        if ((widget.selectedStudentId != null || widget.selectedStudentName != null) && 
            _selectedFee == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (final batchEntry in batchGroups.entries) {
              for (final studentFee in batchEntry.value) {
                if ((widget.selectedStudentId != null && 
                     studentFee.student.id == widget.selectedStudentId) ||
                    (widget.selectedStudentName != null && 
                     studentFee.student.name == widget.selectedStudentName)) {
                  if (studentFee.existingFee != null && mounted) {
                    setState(() {
                      _selectedFee = studentFee.existingFee;
                      _expandedBatches.add(batchEntry.key);
                    });
                    return;
                  }
                }
              }
            }
          });
        }
        
        // Filter batches based on selected filter
        Map<int, List<StudentWithBatchFee>> filteredGroups = {};
        
        for (final entry in batchGroups.entries) {
          List<StudentWithBatchFee> filtered = entry.value;
          
          if (_selectedFilter == 'paid') {
            filtered = entry.value.where((s) => s.feeStatus == 'paid').toList();
          } else if (_selectedFilter == 'pending') {
            filtered = entry.value.where((s) => s.feeStatus == 'pending').toList();
          } else if (_selectedFilter == 'overdue') {
            filtered = entry.value.where((s) => 
              s.feeStatus == 'overdue' || 
              (s.existingFee != null && s.existingFee!.isOverdue)
            ).toList();
          }
          
          if (filtered.isNotEmpty) {
            filteredGroups[entry.key] = filtered;
          }
        }

        if (filteredGroups.isEmpty) {
          return EmptyState.noFees();
        }
        
        // Auto-expand first batch ONLY if we haven't done it yet and no batches are expanded
        if (!_hasAutoExpanded && _expandedBatches.isEmpty && filteredGroups.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _expandedBatches.add(filteredGroups.keys.first);
                _hasAutoExpanded = true; // Mark as done so it doesn't run again
              });
            }
          });
        }

        // Sort batches by name
        final sortedBatches = filteredGroups.entries.toList()
          ..sort((a, b) {
            final nameA = a.value.first.batch.batchName;
            final nameB = b.value.first.batch.batchName;
            return nameA.compareTo(nameB);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedBatches.map((batchEntry) {
            final batchId = batchEntry.key;
            final studentFees = batchEntry.value;
            final batchName = studentFees.first.batch.batchName;
            final batchFeeAmount = studentFees.first.batchFeeAmount;
            final isExpanded = _expandedBatches.contains(batchId);
            
            // Calculate batch stats
            double batchPending = 0;
            double batchPaid = 0;
            double batchOverdue = 0;
            
            for (final studentFee in studentFees) {
              if (studentFee.existingFee != null) {
                final fee = studentFee.existingFee!;
                final pendingAmount = fee.pendingAmount;
                if (fee.status == 'paid') {
                  batchPaid += fee.totalPaid;
                } else if (fee.isOverdue) {
                  batchOverdue += pendingAmount;
                } else {
                  batchPending += pendingAmount;
                }
              } else {
                // Fee not created yet, use batch fee amount as pending
                batchPending += studentFee.batchFeeAmount;
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
                              '${studentFees.length} student${studentFees.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          // Show batch fee amount
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingS,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: Text(
                              '₹${batchFeeAmount.toStringAsFixed(0)}/student',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
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
                    ...studentFees.map((studentFee) => _buildStudentFeeCard(studentFee)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStudentFeeCard(StudentWithBatchFee studentFee) {
    final hasFee = studentFee.hasFee;
    final fee = studentFee.existingFee;
    
    return Container(
      margin: const EdgeInsets.only(
        left: AppDimensions.paddingM,
        right: AppDimensions.paddingM,
        bottom: AppDimensions.spacingS,
      ),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToStudentProfile(studentFee.student.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentFee.student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Batch: ${studentFee.batch.batchName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (hasFee && fee != null)
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
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingM,
                          vertical: AppDimensions.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: const Text(
                          'PENDING',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: AppDimensions.spacingS),
                    // 3-dots menu
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      color: AppColors.cardBackground,
                      onSelected: (value) {
                        if (value == 'edit' && hasFee && fee != null) {
                          _editFee(studentFee, fee);
                        } else if (value == 'view' && hasFee && fee != null) {
                          _viewFeeDetails(fee);
                        }
                      },
                      itemBuilder: (context) => [
                        if (hasFee && fee != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: AppColors.textPrimary),
                                SizedBox(width: 8),
                                Text('Edit Fee', style: TextStyle(color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        if (hasFee && fee != null)
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18, color: AppColors.textPrimary),
                                SizedBox(width: 8),
                                Text('View Details', style: TextStyle(color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasFee && fee != null)
                  Text(
                    'Due: ${_formatDate(fee.dueDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Text(
                    'Fee: ₹${studentFee.batchFeeAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                Text(
                  hasFee && fee != null
                      ? '₹${fee.pendingAmount.toStringAsFixed(0)} pending'
                      : '₹${studentFee.batchFeeAmount.toStringAsFixed(0)} pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: (hasFee && fee != null && fee.pendingAmount > 0) || 
                           (!hasFee && studentFee.batchFeeAmount > 0)
                        ? AppColors.error 
                        : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            // Add Payment button for all students
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddPaymentForStudent(studentFee),
                icon: const Icon(Icons.payment, size: 16),
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
      ),
    );
  }

  /// Auto-create fee if it doesn't exist, then return the fee
  Future<Fee> _ensureFeeExists(StudentWithBatchFee studentFee) async {
    if (studentFee.hasFee && studentFee.existingFee != null) {
      return studentFee.existingFee!;
    }

    // Auto-create fee with batch fee amount and default due date (end of current month)
    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month + 1, 0); // Last day of current month

    final feeData = {
      'student_id': studentFee.student.id,
      'batch_id': studentFee.batch.id,
      'amount': studentFee.batchFeeAmount,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'payee_student_id': studentFee.student.id, // Default to student themselves
    };

    final feeService = ref.read(feeServiceProvider);
    final createdFee = await feeService.createFee(feeData);
    
    // Invalidate providers to refresh the list
    ref.invalidate(studentsWithBatchFeesProvider);
    
    return createdFee;
  }

  /// Show add payment dialog, auto-creating fee if needed
  Future<void> _showAddPaymentForStudent(StudentWithBatchFee studentFee) async {
    try {
      // Show loading indicator
      if (mounted) {
        SuccessSnackbar.show(context, 'Preparing payment...', duration: const Duration(seconds: 1));
      }

      // Ensure fee exists (auto-create if needed)
      final fee = await _ensureFeeExists(studentFee);
      
      // Refresh the provider to update the UI
      ref.invalidate(studentsWithBatchFeesProvider);
      
      // Note: The fee returned from createFee is already fully enriched with all payment data
      // (via enrich_fee_with_payments in backend), so we don't need to fetch it again.
      // The backend doesn't have a GET /fees/{id} endpoint anyway.
      
      // Now show the payment dialog with the fee we already have
      if (mounted) {
        _showAddPaymentDialog(context, fee);
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to prepare payment: ${e.toString()}');
      }
    }
  }

  /// Edit fee dialog
  void _editFee(StudentWithBatchFee studentFee, Fee fee) {
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
            // Invalidate the students with batch fees provider
            widgetRef.invalidate(studentsWithBatchFeesProvider);
            // Note: Dialog will close itself after onSubmit completes
            if (isMounted && mounted) {
              SuccessSnackbar.show(context, 'Fee updated successfully');
            }
          } catch (e) {
            if (isMounted && mounted) {
              SuccessSnackbar.showError(context, 'Failed to update fee: ${e.toString()}');
            }
            // Re-throw to let dialog handle error state
            rethrow;
          }
        },
      ),
    );
  }

  /// View fee details (navigate to deep view)
  void _viewFeeDetails(Fee fee) {
    setState(() {
      _selectedFee = fee;
    });
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
            // Refresh both providers
            widgetRef.invalidate(studentsWithBatchFeesProvider);
            String? currentStatus;
            if (currentFilter != 'all' && currentFilter != 'overdue') {
              currentStatus = currentFilter;
            }
            widgetRef.invalidate(feeListProvider(status: currentStatus));
            // Note: Dialog will close itself after onSubmit completes
            // Don't call Navigator.pop() here to avoid double pop
            if (isMounted && mounted) {
              SuccessSnackbar.show(context, 'Payment recorded successfully');
            }
          } catch (e) {
            if (isMounted && mounted) {
              SuccessSnackbar.showError(context, 'Failed to record payment: ${e.toString()}');
            }
            // Re-throw to let dialog handle error state
            rethrow;
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
          // Refresh both providers
          widgetRef.invalidate(studentsWithBatchFeesProvider);
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
