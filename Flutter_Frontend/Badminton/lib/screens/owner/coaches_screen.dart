import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/coach_provider.dart';
import '../../providers/batch_provider.dart';
import '../../models/coach.dart';
import '../../widgets/forms/add_coach_dialog.dart';
import '../../widgets/forms/edit_coach_dialog.dart';

/// Coaches List Screen - Shows all coaches with add button
class CoachesScreen extends ConsumerStatefulWidget {
  const CoachesScreen({super.key});

  @override
  ConsumerState<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends ConsumerState<CoachesScreen> {
  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(coachListProvider);
    
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
          'Coaches',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: () => _showAddCoachDialog(context),
          ),
        ],
      ),
      body: coachesAsync.when(
        loading: () => const ListSkeleton(itemCount: 5),
        error: (error, stack) => ErrorDisplay(
          message: 'Failed to load coaches: ${error.toString()}',
          onRetry: () => ref.invalidate(coachListProvider),
        ),
        data: (coaches) {
          final sortedCoaches = List<Coach>.from(coaches)
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          if (sortedCoaches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  const Text(
                    'No coaches added yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCoachDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Invite Coach'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(coachListProvider);
              return;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: sortedCoaches.length,
              itemBuilder: (context, index) {
                final coach = sortedCoaches[index];
                return NeumorphicContainer(
                  key: ValueKey(coach.id),
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              coach.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingM,
                              vertical: AppDimensions.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: coach.status == 'active'
                                  ? AppColors.success
                                  : AppColors.error,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: Text(
                              coach.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                            color: AppColors.cardBackground,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, size: 18, color: AppColors.textPrimary),
                                    SizedBox(width: 8),
                                    Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                                  ],
                                ),
                                onTap: () {
                                  Future.delayed(Duration.zero, () {
                                    _showEditCoachDialog(context, coach);
                                  });
                                },
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(
                                      coach.status == 'active' 
                                          ? Icons.person_off 
                                          : Icons.person,
                                      size: 18,
                                      color: coach.status == 'active' 
                                          ? AppColors.error 
                                          : AppColors.success,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      coach.status == 'active' 
                                          ? 'Mark Inactive' 
                                          : 'Mark Active',
                                      style: TextStyle(
                                        color: coach.status == 'active' 
                                            ? AppColors.error 
                                            : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Future.delayed(Duration.zero, () {
                                    _toggleCoachStatus(context, coach);
                                  });
                                },
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.group, size: 18, color: AppColors.textPrimary),
                                    SizedBox(width: 8),
                                    Text('View Batches', style: TextStyle(color: AppColors.textPrimary)),
                                  ],
                                ),
                                onTap: () {
                                  Future.delayed(Duration.zero, () {
                                    _showCoachBatches(context, coach);
                                  });
                                },
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: AppColors.error),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: AppColors.error)),
                                  ],
                                ),
                                onTap: () {
                                  Future.delayed(Duration.zero, () {
                                    _showDeleteConfirmation(context, coach);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: coach.email,
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: coach.phone,
                      ),
                      if (coach.specialization != null && coach.specialization!.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingS),
                        _InfoRow(
                          icon: Icons.sports_tennis_outlined,
                          label: 'Specialization',
                          value: coach.specialization!,
                        ),
                      ],
                      if (coach.experienceYears != null) ...[
                        const SizedBox(height: AppDimensions.spacingS),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Experience',
                          value: '${coach.experienceYears} years',
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
    );
  }

  void _showAddCoachDialog(BuildContext context) {
    final widgetRef = ref;
    final isMounted = mounted;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AddCoachDialog(
        onSubmit: (coachData) async {
          // Dialog handles invitation internally, just refresh the list
          if (isMounted && mounted) {
            widgetRef.invalidate(coachListProvider);
            SuccessSnackbar.show(context, 'Coach invitation sent successfully');
          }
        },
      ),
    );
  }

  void _showEditCoachDialog(BuildContext context, Coach coach) {
    final widgetRef = ref;
    final isMounted = mounted;
    
    showDialog(
      context: context,
      builder: (dialogContext) => EditCoachDialog(
        coach: coach,
        onSubmit: (coachData) async {
          try {
            await widgetRef.read(coachListProvider.notifier).updateCoach(coach.id, coachData);
            if (isMounted && mounted) {
              Navigator.of(dialogContext).pop();
              SuccessSnackbar.show(context, 'Coach updated successfully');
            }
          } catch (e) {
            if (isMounted && mounted) {
              SuccessSnackbar.showError(context, 'Failed to update coach: ${e.toString()}');
            }
          }
        },
      ),
    );
  }

  void _showCoachBatches(BuildContext context, Coach coach) async {
    try {
      final allBatches = await ref.read(batchListProvider.future);
      final assignedBatches = allBatches
          .where((batch) => batch.assignedCoachId == coach.id)
          .toList();

      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              'Batches Assigned to ${coach.name}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: assignedBatches.isEmpty
                  ? const Text(
                      'No batches assigned',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: assignedBatches.length,
                      itemBuilder: (context, index) {
                        final batch = assignedBatches[index];
                        return ListTile(
                          title: Text(
                            batch.batchName,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            '${batch.timing} • ${batch.period}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to load batches: ${e.toString()}');
      }
    }
  }

  void _toggleCoachStatus(BuildContext context, Coach coach) async {
    try {
      final newStatus = coach.status == 'active' ? 'inactive' : 'active';
      await ref.read(coachListProvider.notifier).updateCoach(coach.id, {'status': newStatus});
      if (mounted) {
        SuccessSnackbar.show(context, 'Coach ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully');
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to update coach status: ${e.toString()}');
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, Coach coach) {
    final widgetRef = ref;
    final isMounted = mounted;
    
    ConfirmationDialog.showDelete(
      context,
      coach.name,
      onConfirm: () async {
        try {
          await widgetRef.read(coachListProvider.notifier).deleteCoach(coach.id);
          if (isMounted && mounted) {
            SuccessSnackbar.show(context, 'Coach deleted successfully');
          }
        } catch (e) {
          if (isMounted && mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete coach: ${e.toString()}');
          }
        }
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
