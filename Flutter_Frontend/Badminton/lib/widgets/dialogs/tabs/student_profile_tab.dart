import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/success_snackbar.dart';
import '../../../widgets/common/confirmation_dialog.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/batch_provider.dart';
import '../../../models/student.dart';
import '../../../core/services/fee_service.dart';
import '../../../core/services/batch_enrollment_service.dart';
import '../../common/error_widget.dart';
import '../../common/skeleton_screen.dart';
import '../../../core/utils/contact_utils.dart';

import '../../../providers/auth_provider.dart';

/// Profile Tab - Shows student information and management actions
class StudentProfileTab extends ConsumerStatefulWidget {
  final Student student;
  final VoidCallback? onStudentUpdated;

  const StudentProfileTab({
    super.key,
    required this.student,
    this.onStudentUpdated,
  });

  @override
  ConsumerState<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends ConsumerState<StudentProfileTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Contact Information
          _buildContactInfo(),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Batches Section
          _buildBatchesSection(),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Fee Status Summary
          _buildFeeStatusSummary(),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Action Buttons - Only for Owners
          _buildActionButtons(ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.student.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.student.status == 'active'
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    widget.student.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            children: [
              if (widget.student.email.isNotEmpty)
                _buildInfoRow(
                  Icons.email_outlined, 
                  'Email', 
                  widget.student.email,
                  onTap: () => ContactUtils.launchEmail(widget.student.email),
                ),
              if (widget.student.email.isNotEmpty && widget.student.phone.isNotEmpty)
                const Divider(color: AppColors.textSecondary, height: 24),
              if (widget.student.phone.isNotEmpty)
                _buildInfoRow(
                  Icons.phone_outlined, 
                  'Phone', 
                  widget.student.phone,
                  onTap: () => ContactUtils.showContactOptions(context, widget.student.phone, name: widget.student.name),
                ),
            ],
          ),
        ),
        if (widget.student.guardianName != null || widget.student.guardianPhone != null) ...[
          const SizedBox(height: AppDimensions.spacingM),
          const Text(
            'Guardian Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: [
                if (widget.student.guardianName != null)
                  _buildInfoRow(
                    Icons.person_outline,
                    'Guardian Name',
                    widget.student.guardianName!,
                  ),
                if (widget.student.guardianName != null && widget.student.guardianPhone != null)
                  const Divider(color: AppColors.textSecondary, height: 24),
                if (widget.student.guardianPhone != null)
                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Guardian Phone',
                    widget.student.guardianPhone!,
                    onTap: () => ContactUtils.showContactOptions(
                      context, 
                      widget.student.guardianPhone!, 
                      name: 'Guardian: ${widget.student.guardianName ?? widget.student.name}',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBatchesSection() {
    final studentBatchesAsync = ref.watch(studentBatchesProvider(widget.student.id));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enrolled Batches',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        studentBatchesAsync.when(
          loading: () => const ListSkeleton(itemCount: 2),
          error: (error, stack) => ErrorDisplay(
            message: 'Failed to load batches',
            onRetry: () => ref.invalidate(studentBatchesProvider(widget.student.id)),
          ),
          data: (batches) {
            if (batches.isEmpty) {
              return NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: const Center(
                  child: Text(
                    'No batches assigned',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }
            return NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Wrap(
                spacing: AppDimensions.spacingS,
                runSpacing: AppDimensions.spacingS,
                children: batches.map((batch) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      batch.batchName,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeeStatusSummary() {
    return FutureBuilder<String?>(
      future: _getFeeStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final feeStatus = snapshot.data;
        if (feeStatus == null) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fee Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: AppDimensions.spacingM),
                  const Text(
                    'Status: ',
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
                      color: _getFeeStatusColor(feeStatus),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      feeStatus.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(WidgetRef ref) {
    // Check if user is owner
    final authState = ref.watch(authProvider);
    final isOwner = authState.maybeWhen(
      data: (state) => state is Authenticated && state.userType == 'owner',
      orElse: () => false,
    );

    if (!isOwner) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _manageBatches(),
            icon: const Icon(Icons.group_add, size: 18),
            label: const Text('Manage Batches'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _toggleStatus(),
            icon: Icon(
              widget.student.status == 'active' ? Icons.person_off : Icons.person,
              size: 18,
            ),
            label: Text(widget.student.status == 'active' ? 'Mark Inactive' : 'Mark Active'),
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.student.status == 'active' 
                  ? AppColors.error 
                  : AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _deleteStudent(),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete Student'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                onTap != null 
                  ? InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accent.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.open_in_new, size: 14, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Future<String?> _getFeeStatus() async {
    try {
      final feeService = ref.read(feeServiceProvider);
      final fees = await feeService.getFees(studentId: widget.student.id);
      if (fees.isNotEmpty) {
        final pendingFees = fees.where((f) => f.status != 'paid').toList();
        if (pendingFees.isNotEmpty) {
          final overdueFees = pendingFees.where((f) => f.isOverdue).toList();
          return overdueFees.isNotEmpty ? 'overdue' : 'pending';
        } else {
          return 'paid';
        }
      }
    } catch (e) {
      // Skip if fees fetch fails
    }
    return null;
  }

  Color _getFeeStatusColor(String status) {
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

  void _manageBatches() async {
    try {
      final studentBatches = await ref.read(studentBatchesProvider(widget.student.id).future);
      
      if (studentBatches.isEmpty) {
        _showAddBatchDialog([]);
        return;
      }

      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Manage Batches', style: TextStyle(color: AppColors.textPrimary)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Batches:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    ...studentBatches.map((batch) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                        padding: const EdgeInsets.all(AppDimensions.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                batch.batchName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                              onPressed: () async {
                                try {
                                  await BatchEnrollmentHelper.removeStudent(ref, batch.id, widget.student.id);
                                  if (mounted && Navigator.of(dialogContext).canPop()) {
                                    Navigator.of(dialogContext).pop();
                                    SuccessSnackbar.show(context, 'Student removed from batch successfully');
                                  }
                                } catch (e) {
                                  final errorMessage = e.toString().replaceFirst('Exception: ', '');
                                  SuccessSnackbar.showError(context, 'Failed to remove from batch: $errorMessage');
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppDimensions.spacingM),
                    const Divider(color: AppColors.textSecondary),
                    const SizedBox(height: AppDimensions.spacingM),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await _showAddBatchDialog(studentBatches);
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Another Batch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      SuccessSnackbar.showError(context, 'Failed to load batches: ${e.toString()}');
    }
  }

  Future<void> _showAddBatchDialog(List batches) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      final allBatches = await batchService.getBatches();
      
      if (allBatches.isEmpty) {
        SuccessSnackbar.showInfo(context, 'No batches available. Please create a batch first.');
        return;
      }

      final existingBatchIds = batches.map((b) => b.id).toSet();
      final availableBatches = allBatches.where((b) => !existingBatchIds.contains(b.id)).toList();

      if (availableBatches.isEmpty) {
        SuccessSnackbar.showInfo(context, 'Student is already enrolled in all available batches.');
        return;
      }

      final selectedBatchIdNotifier = ValueNotifier<int?>(null);
      
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Add Batch', style: TextStyle(color: AppColors.textPrimary)),
          content: ValueListenableBuilder<int?>(
            valueListenable: selectedBatchIdNotifier,
            builder: (context, selectedBatchId, _) {
              return DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Select Batch',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                items: availableBatches.map((batch) {
                  return DropdownMenuItem<int>(
                    value: batch.id,
                    child: Text(batch.batchName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedBatchIdNotifier.value = value;
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<int?>(
              valueListenable: selectedBatchIdNotifier,
              builder: (context, selectedBatchId, _) {
                return TextButton(
                  onPressed: selectedBatchId == null
                      ? null
                      : () async {
                          try {
                            await BatchEnrollmentHelper.enrollStudent(ref, selectedBatchId, widget.student.id);
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              SuccessSnackbar.show(context, 'Student added to batch successfully');
                            }
                          } catch (e) {
                            final errorMessage = e.toString().replaceFirst('Exception: ', '');
                            SuccessSnackbar.showError(context, 'Failed to add batch: $errorMessage');
                          }
                        },
                  child: const Text('Add Batch'),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      SuccessSnackbar.showError(context, 'Failed to load batches: $errorMessage');
    }
  }

  void _toggleStatus() async {
    try {
      final newStatus = widget.student.status == 'active' ? 'inactive' : 'active';
      await ref.read(studentListProvider.notifier).updateStudent(widget.student.id, {'status': newStatus});
      if (mounted) {
        SuccessSnackbar.show(context, 'Student ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully');
        widget.onStudentUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to update student status: ${e.toString()}');
      }
    }
  }

  void _deleteStudent() {
    ConfirmationDialog.showDelete(
      context,
      widget.student.name,
      onConfirm: () async {
        try {
          await ref.read(studentListProvider.notifier).deleteStudent(widget.student.id);
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog
            SuccessSnackbar.show(context, 'Student deleted successfully');
          }
        } catch (e) {
          if (mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete student: ${e.toString()}');
          }
        }
      },
    );
  }
}
