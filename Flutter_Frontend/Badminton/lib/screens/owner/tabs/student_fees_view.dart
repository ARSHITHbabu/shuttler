import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/theme/neumorphic_styles.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/skeleton_screen.dart';
import '../../../widgets/common/success_snackbar.dart';
import '../../../widgets/common/confirmation_dialog.dart';
import '../../../models/fee.dart';
import '../../../models/student_with_batch_fee.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/fee_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../widgets/forms/add_payment_dialog.dart';
import '../../../widgets/forms/edit_fee_dialog.dart';
import '../../../models/fee_payment.dart';
import '../../../models/batch_fee_group.dart';
import '../student_profile_screen.dart';
import 'package:intl/intl.dart';

class StudentFeesView extends ConsumerStatefulWidget {
  final int? selectedStudentId;
  final String? selectedStudentName;

  const StudentFeesView({
    super.key,
    this.selectedStudentId,
    this.selectedStudentName,
  });

  @override
  ConsumerState<StudentFeesView> createState() => _StudentFeesViewState();
}

class _StudentFeesViewState extends ConsumerState<StudentFeesView> {
  String _selectedFilter = 'all'; 
  Fee? _selectedFee; 
  int? _selectedBatchId; 

  @override
  Widget build(BuildContext context) {
    if (_selectedFee != null) {
      return _buildDeepView();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(studentsWithBatchFeesProvider);
            String? statusFilter;
            if (_selectedFilter != 'all') {
              statusFilter = _selectedFilter == 'overdue' ? null : _selectedFilter;
            }
            ref.invalidate(feeListProvider(status: statusFilter));
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                        vertical: AppDimensions.paddingM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedBatchId == null)
                            _buildBatchList()
                          else
                            _buildBatchFeeDetailView(),
                          
                          const SizedBox(height: 100), // Bottom nav space
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBatchList() {
    final studentsWithFeesAsync = ref.watch(studentsWithBatchFeesProvider);

    return studentsWithFeesAsync.when(
      loading: () => const ListSkeleton(itemCount: 5),
      error: (error, stack) => ErrorDisplay(
        message: 'Failed to load fees: ${error.toString()}',
        onRetry: () => ref.invalidate(studentsWithBatchFeesProvider),
      ),
      data: (batchGroups) {
        if (batchGroups.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Text('No batches with students found', style: TextStyle(color: AppColors.textSecondary)),
          ));
        }

        return Column(
          children: batchGroups.entries.map((entry) => _buildBatchFeeCard(entry.value)).toList(),
        );
      },
    );
  }

  Widget _buildBatchFeeCard(BatchFeeGroup group) {
    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      onTap: () => setState(() => _selectedBatchId = group.batchId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  group.batchName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          
          // Stats Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip('Total: ${group.totalStudents}', AppColors.info),
              _buildStatChip('Paid: ${group.paidCount}', AppColors.success),
              _buildStatChip('Pending: ${group.pendingCount}', AppColors.warning),
              if (group.overdueCount > 0)
                _buildStatChip('Overdue: ${group.overdueCount}', AppColors.error),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collected: ₹${group.totalCollectedAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Expected: ₹${group.totalExpectedAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Collection Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: group.totalExpectedAmount > 0 ? group.totalCollectedAmount / group.totalExpectedAmount : 0,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildBatchFeeDetailView() {
    final studentsWithFeesAsync = ref.watch(studentsWithBatchFeesProvider);
    
    return studentsWithFeesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => ErrorDisplay(message: e.toString()),
      data: (batchGroups) {
        final group = batchGroups[_selectedBatchId];
        if (group == null) return const Text('Batch not found');
        
        var filteredStudents = group.students;
        if (_selectedFilter != 'all') {
          filteredStudents = filteredStudents.where((s) {
            final isOverdue = s.existingFee?.isOverdue ?? false;
            if (_selectedFilter == 'overdue') return isOverdue;
            if (_selectedFilter == 'pending') return s.existingFee == null || (s.existingFee!.status == 'pending' && !isOverdue);
            return s.existingFee?.status == _selectedFilter;
          }).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            InkWell(
              onTap: () => setState(() { _selectedBatchId = null; _selectedFilter = 'all'; }),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('All Batches', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  const SizedBox(width: 8),
                  const Text('/', style: TextStyle(color: AppColors.textTertiary)),
                  const SizedBox(width: 8),
                  Text(group.batchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab('All', 'all'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Paid', 'paid'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Pending', 'pending'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Overdue', 'overdue'),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            
            if (filteredStudents.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No students match filter', style: TextStyle(color: AppColors.textSecondary))))
            else
              ...filteredStudents.map((s) => _buildStudentFeeRow(s)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentFeeRow(StudentWithBatchFee studentFee) {
    final fee = studentFee.existingFee;
    final status = fee?.isOverdue ?? false ? 'overdue' : (fee?.status ?? 'pending');
    
    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: () {
        if (fee != null) {
          setState(() => _selectedFee = fee);
        } else {
          _showAddPaymentDialogForVirtual(studentFee);
        }
      },
      child: Row(
        children: [
           CircleAvatar(
             radius: 20,
             backgroundColor: AppColors.surfaceLight,
             backgroundImage: studentFee.student.profilePhoto != null ? NetworkImage(studentFee.student.profilePhoto!) : null,
             child: studentFee.student.profilePhoto == null 
                 ? Text(studentFee.student.name[0], style: const TextStyle(color: AppColors.textPrimary)) 
                 : null,
           ),
           const SizedBox(width: AppDimensions.spacingM),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(studentFee.student.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                 const SizedBox(height: 2),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                   decoration: BoxDecoration(
                     color: _getStatusColor(status).withOpacity(0.1),
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: Text(
                     status.toUpperCase(), 
                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(status))
                   ),
                 ),
               ],
             ),
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(
                 '₹${studentFee.pendingAmount.toStringAsFixed(0)}',
                 style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
               ),
               const Text('Due', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
             ],
           ),
           const SizedBox(width: AppDimensions.spacingM),
           const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid': return AppColors.success;
      case 'pending': return AppColors.warning;
      case 'overdue': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  Widget _buildDeepView() {
    final fee = _selectedFee!;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), 
            onPressed: () => setState(() => _selectedFee = null),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Fee Details: ${fee.studentName ?? "Student"}', 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Expanded(
            child: SingleChildScrollView(
              child: _buildFeeDetailCard(fee),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeDetailCard(Fee fee) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${fee.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              _buildStatChip(fee.status.toUpperCase(), _getStatusColor(fee.status)),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          _buildInfoItem(Icons.calendar_today, 'Due Date', DateFormat('dd MMM, yyyy').format(fee.dueDate)),
          _buildInfoItem(Icons.check_circle, 'Total Paid', '₹${fee.totalPaid.toStringAsFixed(2)}'),
          _buildInfoItem(Icons.pending, 'Pending', '₹${fee.pendingAmount.toStringAsFixed(2)}', color: fee.pendingAmount > 0 ? AppColors.error : AppColors.success),
          
          if (fee.payments != null && fee.payments!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingL),
            const Text('Payment History', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const Divider(color: AppColors.border),
            ...fee.payments!.map((p) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('₹${p.amount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: Text(DateFormat('dd MMM, yyyy').format(p.paidDate), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => _confirmDeletePayment(fee, p)),
            )),
          ],
          
          const SizedBox(height: AppDimensions.spacingL),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAddPaymentDialog(fee),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                  ),
                  child: const Text('Add Payment'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _showEditFeeDialog(fee),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                ),
                child: const Text('Edit Fee'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }

  Future<Fee> _ensureFeeExists(Fee fee) async {
    if (fee.id != -1) return fee;
    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month + 1, 0);
    final data = {
      'student_id': fee.studentId,
      'batch_id': fee.batchId,
      'amount': fee.amount,
      'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
    };
    final created = await ref.read(feeServiceProvider).createFee(data);
    ref.invalidate(studentsWithBatchFeesProvider);
    return created;
  }

  void _showAddPaymentDialog(Fee fee) async {
    try {
      final effectiveFee = await _ensureFeeExists(fee);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AddPaymentDialog(
          fee: effectiveFee,
          onSubmit: (data) async {
            await ref.read(feeServiceProvider).createFeePayment(effectiveFee.id, data);
            ref.invalidate(studentsWithBatchFeesProvider);
            ref.invalidate(feeListProvider);
            if (mounted) {
              Navigator.pop(ctx);
              final updated = await ref.read(feeServiceProvider).getFeeById(effectiveFee.id);
              setState(() => _selectedFee = updated);
              SuccessSnackbar.show(context, 'Payment recorded');
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) SuccessSnackbar.showError(context, e.toString());
    }
  }

  void _showAddPaymentDialogForVirtual(StudentWithBatchFee sf) {
    final virtualFee = Fee(
      id: -1,
      studentId: sf.student.id,
      batchId: sf.batch.id,
      amount: sf.batchFeeAmount,
      totalPaid: 0,
      pendingAmount: sf.batchFeeAmount,
      dueDate: DateTime.now(),
      status: 'pending',
      studentName: sf.student.name,
    );
    _showAddPaymentDialog(virtualFee);
  }

  void _showEditFeeDialog(Fee fee) {
    showDialog(
      context: context,
      builder: (ctx) => EditFeeDialog(
        fee: fee,
        onSubmit: (data) async {
          await ref.read(feeListProvider(status: null).notifier).updateFee(fee.id, data);
          if (mounted) {
            Navigator.pop(ctx);
            final updated = await ref.read(feeServiceProvider).getFeeById(fee.id);
            setState(() => _selectedFee = updated);
            SuccessSnackbar.show(context, 'Fee updated');
          }
        },
      ),
    );
  }

  void _confirmDeletePayment(Fee fee, FeePayment payment) {
    ConfirmationDialog.show(
      context,
      'Delete Payment',
      'Delete payment of ₹${payment.amount}?',
      onConfirm: () async {
        await ref.read(feeServiceProvider).deleteFeePayment(fee.id, payment.id);
        final updated = await ref.read(feeServiceProvider).getFeeById(fee.id);
        setState(() => _selectedFee = updated);
        ref.invalidate(studentsWithBatchFeesProvider);
      },
    );
  }
}
