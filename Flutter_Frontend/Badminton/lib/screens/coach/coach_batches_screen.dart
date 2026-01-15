import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
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
  int? _expandedBatchId;

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
      loading: () => const Center(child: LoadingSpinner()),
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
                          isExpanded: _expandedBatchId == batch.id,
                          onTap: () {
                            setState(() {
                              _expandedBatchId = _expandedBatchId == batch.id ? null : batch.id;
                            });
                          },
                          onViewStudents: () {
                            _showBatchStudents(context, batch);
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: LoadingSpinner()),
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

  void _showBatchStudents(BuildContext context, Batch batch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BatchStudentsSheet(batch: batch),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onViewStudents;

  const _BatchCard({
    required this.batch,
    required this.isExpanded,
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
                        const Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          batch.timing,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textSecondary,
              ),
            ],
          ),

          if (isExpanded) ...[
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(),
            const SizedBox(height: AppDimensions.spacingM),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Days',
              value: batch.period,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            if (batch.location != null)
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: batch.location!,
              ),
            const SizedBox(height: AppDimensions.spacingS),
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Capacity',
              value: '${batch.capacity} students',
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _InfoRow(
              icon: Icons.currency_rupee_outlined,
              label: 'Fees',
              value: '₹${batch.fees}',
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SizedBox(
              width: double.infinity,
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                onTap: onViewStudents,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 20,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: AppDimensions.spacingS),
                    Text(
                      'View Students',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BatchStudentsSheet extends ConsumerStatefulWidget {
  final Batch batch;

  const _BatchStudentsSheet({required this.batch});

  @override
  ConsumerState<_BatchStudentsSheet> createState() => _BatchStudentsSheetState();
}

class _BatchStudentsSheetState extends ConsumerState<_BatchStudentsSheet> {
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    final batchService = ref.read(batchServiceProvider);
    _studentsFuture = batchService.getBatchStudents(widget.batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.batch.batchName} - Students',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(),

          // Students List
          Expanded(
            child: FutureBuilder<List<Student>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingSpinner());
                }

                if (snapshot.hasError) {
                  return ErrorDisplay(
                    message: 'Failed to load students',
                    onRetry: () {
                      setState(() {
                        _loadStudents();
                      });
                    },
                  );
                }

                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return const Center(
                    child: Text(
                      'No students enrolled in this batch',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.background,
                              child: Text(
                                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (student.phone != null && student.phone!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      student.phone!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
