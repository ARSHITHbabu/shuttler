import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../models/fee.dart';
import '../../models/student_with_batch_fee.dart';
import '../../providers/fee_provider.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

/// Coach Fees Screen - Read-only view of fees with statistics and details
/// Coaches can view all fee information but cannot add, edit, or delete fees
class CoachFeesScreen extends ConsumerStatefulWidget {
  final int? selectedStudentId;
  final String? selectedStudentName;

  const CoachFeesScreen({
    super.key,
    this.selectedStudentId,
    this.selectedStudentName,
  });

  @override
  ConsumerState<CoachFeesScreen> createState() => _CoachFeesScreenState();
}

class _CoachFeesScreenState extends ConsumerState<CoachFeesScreen> {
  String _selectedFilter = 'all'; // 'all', 'paid', 'pending', 'overdue' - for batch detail view
  Fee? _selectedFee; // For deep view
  int? _selectedBatchId; // Track selected batch for detail view

  @override
  void initState() {
    super.initState();
    _secureScreen();
  }

  Future<void> _secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void dispose() {
    FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    super.dispose();
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
                      
                      // Show batch list or batch detail view
                      if (_selectedBatchId == null)
                        _buildBatchList()
                      else
                        _buildBatchFeeDetailView(),
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

  Widget _buildBatchList() {
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
            _selectedFee == null && _selectedBatchId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (final batchEntry in batchGroups.entries) {
              for (final studentFee in batchEntry.value.students) {
                if ((widget.selectedStudentId != null && 
                     studentFee.student.id == widget.selectedStudentId) ||
                    (widget.selectedStudentName != null && 
                     studentFee.student.name == widget.selectedStudentName)) {
                  if (studentFee.existingFee != null && mounted) {
                    setState(() {
                      _selectedFee = studentFee.existingFee;
                      _selectedBatchId = batchEntry.key;
                    });
                    return;
                  }
                }
              }
            }
          });
        }

        if (batchGroups.isEmpty) {
          return EmptyState.noFees();
        }

        // Sort batches by name
        final sortedBatches = batchGroups.entries.toList()
          ..sort((a, b) {
            final nameA = a.value.batch.batchName;
            final nameB = b.value.batch.batchName;
            return nameA.compareTo(nameB);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedBatches.map((batchEntry) {
            final batchId = batchEntry.key;
            final group = batchEntry.value;
            final studentFees = group.students;
            final batch = group.batch;
            final batchName = batch.batchName;
            
            // Parse batch fee amount
            double batchFeeAmount = 0;
            try {
              final feeString = batch.fees.replaceAll(RegExp(r'[\$,\s]'), '');
              batchFeeAmount = double.parse(feeString);
            } catch (e) {
              batchFeeAmount = 0;
            }
            
            // Calculate batch stats for preview
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
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              onTap: () {
                setState(() {
                  _selectedBatchId = batchId;
                });
              },
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
                        if (batch.timeRange.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            batch.timeRange,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: AppDimensions.spacingM,
                          children: [
                            if (batchPending > 0)
                              Text(
                                '\$${batchPending.toStringAsFixed(0)} pending',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.warning,
                                ),
                              ),
                            if (batchPaid > 0)
                              Text(
                                '\$${batchPaid.toStringAsFixed(0)} paid',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                ),
                              ),
                            if (batchOverdue > 0)
                              Text(
                                '\$${batchOverdue.toStringAsFixed(0)} overdue',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      '\$${batchFeeAmount.toStringAsFixed(0)}/student',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBatchFeeDetailView() {
    if (_selectedBatchId == null) return const SizedBox.shrink();

    final studentsWithFeesAsync = ref.watch(studentsWithBatchFeesProvider);

    return studentsWithFeesAsync.when(
      loading: () => const ListSkeleton(itemCount: 5),
      error: (error, stack) => ErrorDisplay(
        message: 'Failed to load batch fees: ${error.toString()}',
        onRetry: () {
          ref.invalidate(studentsWithBatchFeesProvider);
        },
      ),
      data: (batchGroups) {
        final group = batchGroups[_selectedBatchId];
        if (group == null) {
          return const Center(child: Text('Batch not found'));
        }
        
        final studentFees = group.students;
        final batch = group.batch;
        final batchName = batch.batchName;
        final batchTimeRange = batch.timeRange;

        if (studentFees.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBatchDetailHeader(batchName, batchTimeRange),
              const SizedBox(height: AppDimensions.spacingL),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
                      SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'No students assigned to this batch.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Filter students based on selected filter
        List<StudentWithBatchFee> filteredStudents = studentFees;
        if (_selectedFilter == 'paid') {
          filteredStudents = studentFees.where((s) => s.feeStatus == 'paid').toList();
        } else if (_selectedFilter == 'partial') {
          filteredStudents = studentFees.where((s) => s.feeStatus == 'partial').toList();
        } else if (_selectedFilter == 'pending') {
          filteredStudents = studentFees.where((s) => s.feeStatus == 'pending').toList();
        } else if (_selectedFilter == 'overdue') {
          filteredStudents = studentFees.where((s) =>
            s.feeStatus == 'overdue' ||
            (s.existingFee != null && s.existingFee!.isOverdue)
          ).toList();
        }

        // Calculate batch-specific stats
        double batchPending = 0;
        double batchPaid = 0;
        double batchOverdue = 0;
        double totalFeeAmount = 0;
        int totalStudents = studentFees.length;
        
        for (final studentFee in studentFees) {
          totalFeeAmount += studentFee.batchFeeAmount;
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

        final collectionRate = totalFeeAmount > 0 
            ? ((batchPaid / totalFeeAmount) * 100).toStringAsFixed(0)
            : '0';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Header with Back Button
            _buildBatchDetailHeader(batchName, batchTimeRange),
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
                    label: 'Partial',
                    isSelected: _selectedFilter == 'partial',
                    onTap: () => setState(() => _selectedFilter = 'partial'),
                    color: Colors.teal,
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
            
            // Dashboard Statistics
            _buildBatchDashboard(
              totalStudents: totalStudents,
              totalFeeAmount: totalFeeAmount,
              paidAmount: batchPaid,
              pendingAmount: batchPending,
              overdueAmount: batchOverdue,
              collectionRate: collectionRate,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            
            // Student List Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: Text(
                'Student Fees',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            
            // Student List
            if (filteredStudents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppDimensions.paddingM),
                child: Text(
                  'No students match the selected filter',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...filteredStudents.map((studentFee) => _buildStudentFeeCard(studentFee)),
          ],
        );
      },
    );
  }

  Widget _buildBatchDetailHeader(String batchName, String batchTimeRange) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _selectedBatchId = null;
                _selectedFilter = 'all'; // Reset filter when going back
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batchName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (batchTimeRange.isNotEmpty)
                  Text(
                    batchTimeRange,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchDashboard({
    required int totalStudents,
    required double totalFeeAmount,
    required double paidAmount,
    required double pendingAmount,
    required double overdueAmount,
    required String collectionRate,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total Students',
            value: totalStudents.toString(),
            color: AppColors.textSecondary,
          ),
          _SummaryItem(
            label: 'Total Fee',
            value: '\$${totalFeeAmount.toStringAsFixed(0)}',
            color: AppColors.textPrimary,
          ),
          _SummaryItem(
            label: 'Paid',
            value: '\$${paidAmount.toStringAsFixed(0)}',
            color: AppColors.success,
          ),
          _SummaryItem(
            label: 'Pending',
            value: '\$${pendingAmount.toStringAsFixed(0)}',
            color: AppColors.warning,
          ),
          _SummaryItem(
            label: 'Overdue',
            value: '\$${overdueAmount.toStringAsFixed(0)}',
            color: AppColors.error,
          ),
          if (totalFeeAmount > 0)
            _SummaryItem(
              label: 'Collection',
              value: '$collectionRate%',
              color: AppColors.accent,
            ),
        ],
      ),
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
                    ],
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
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
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
                    // View Details button (read-only)
                    if (hasFee && fee != null)
                      IconButton(
                        icon: const Icon(
                          Icons.visibility,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => _viewFeeDetails(fee),
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
                    'Fee: \$${studentFee.batchFeeAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                Text(
                  hasFee && fee != null
                      ? '\$${fee.pendingAmount.toStringAsFixed(0)} pending'
                      : '\$${studentFee.batchFeeAmount.toStringAsFixed(0)} pending',
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
          ],
        ),
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
                  Text(
                    fee.studentName ?? 'Student #${fee.studentId}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
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
                        '\$${fee.amount.toStringAsFixed(2)}',
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
                        '\$${fee.totalPaid.toStringAsFixed(2)}',
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
                        '\$${fee.pendingAmount.toStringAsFixed(2)}',
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
            
            // Payment History (read-only)
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
                                    '\$${payment.amount.toStringAsFixed(2)}',
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
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'partial':
        return Colors.teal;
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
