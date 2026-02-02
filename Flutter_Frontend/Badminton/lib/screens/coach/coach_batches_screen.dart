import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/batch_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/dialogs/batch_details_dialog.dart';
import '../../widgets/batch/batch_students_sheet.dart';
import '../../models/batch.dart';
import '../../models/student.dart';

/// Coach Batches Screen - View assigned batches (READ-ONLY)
class CoachBatchesScreen extends ConsumerStatefulWidget {
  const CoachBatchesScreen({super.key});

  @override
  ConsumerState<CoachBatchesScreen> createState() => _CoachBatchesScreenState();
}

class _CoachBatchesScreenState extends ConsumerState<CoachBatchesScreen> {
  String _searchQuery = '';

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

                  // Filter batches by search query
                  final filteredBatches = batches.where((batch) {
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
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.batchName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(batch.timing, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onViewStudents,
              icon: const Icon(Icons.people_outline, size: 20),
              label: const Text('View Students'),
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

