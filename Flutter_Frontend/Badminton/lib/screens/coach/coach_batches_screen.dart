import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dialogs/batch_details_dialog.dart';
import '../../widgets/batch/batch_students_sheet.dart';
import '../../models/batch.dart';

/// Coach Batches Screen - View assigned batches (READ-ONLY)
class CoachBatchesScreen extends ConsumerStatefulWidget {
  const CoachBatchesScreen({super.key});

  @override
  ConsumerState<CoachBatchesScreen> createState() => _CoachBatchesScreenState();
}

class _CoachBatchesScreenState extends ConsumerState<CoachBatchesScreen> {
  String _searchQuery = '';
  String _statusFilter = 'active'; // 'active' or 'inactive'

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return const Center(
            child: Text(
              'Please login',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        final coachId = authValue.userId;
        return _buildContent(coachId);
      },
      loading: () => const Center(child: DashboardSkeleton()),
      error: (error, stack) => Center(
        child: Text(
          'Error: ${error.toString()}',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(int coachId) {
    final batchesAsync = ref.watch(coachBatchesProvider(coachId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(coachBatchesProvider(coachId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'My Batches',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Search Bar
              NeumorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search batches...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Status Filter Toggle
              NeumorphicContainer(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterButton(
                        label: 'Active',
                        isSelected: _statusFilter == 'active',
                        onTap: () => setState(() => _statusFilter = 'active'),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _FilterButton(
                        label: 'Inactive',
                        isSelected: _statusFilter == 'inactive',
                        onTap: () => setState(() => _statusFilter = 'inactive'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Batches List
              batchesAsync.when(
                data: (batches) {
                  if (batches.isEmpty) {
                    return NeumorphicContainer(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: const Center(
                        child: Text(
                          'No batches assigned yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  // Filter batches by status and search query
                  final filteredBatches = batches.where((batch) {
                    // Filter by status
                    final status = batch.status.toLowerCase();
                    if (_statusFilter == 'active' && status != 'active') return false;
                    if (_statusFilter == 'inactive' && status == 'active') return false;
                    
                    // Filter by search query
                    if (_searchQuery.isEmpty) return true;
                    return batch.batchName.toLowerCase().contains(_searchQuery) ||
                           batch.timing.toLowerCase().contains(_searchQuery) ||
                           (batch.location?.toLowerCase().contains(_searchQuery) ?? false);
                  }).toList();

                  return Column(
                    children: filteredBatches.map((batch) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                        child: _BatchCard(
                          batch: batch,
                          onTap: () => BatchDetailsDialog.show(context, batch: batch, isOwner: false),
                          onViewStudents: () => BatchStudentsSheet.show(context, batch),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: ListSkeleton(itemCount: 3)),
                error: (error, stack) => ErrorDisplay(
                  message: 'Failed to load batches',
                  onRetry: () => ref.invalidate(coachBatchesProvider(coachId)),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback onTap;
  final VoidCallback onViewStudents;

  const _BatchCard({
    required this.batch,
    required this.onTap,
    required this.onViewStudents,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      onTap: onTap, // Make entire card clickable to open batch details
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
                      batch.batchName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: batch.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Wrap(
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingXs,
            children: [
              _InfoChip(
                icon: Icons.people_outline,
                label: '${batch.capacity} capacity',
              ),
              _InfoChip(
                icon: Icons.currency_rupee,
                label: '${batch.fees}/month',
              ),
              _InfoChip(
                icon: Icons.access_time,
                label: batch.timing,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? Colors.green : Colors.orange,
          width: 0.5,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        boxShadow: NeumorphicStyles.getSmallInsetShadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
