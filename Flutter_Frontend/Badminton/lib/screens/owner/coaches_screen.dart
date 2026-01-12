import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/service_providers.dart';
import '../../models/coach.dart';
import '../../widgets/forms/add_coach_dialog.dart';

/// Coaches List Screen - Shows all coaches with add button
class CoachesScreen extends ConsumerStatefulWidget {
  const CoachesScreen({super.key});

  @override
  ConsumerState<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends ConsumerState<CoachesScreen> {
  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Coach>>(
        future: ref.read(coachServiceProvider).getCoaches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingSpinner());
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              message: 'Failed to load coaches',
              onRetry: () => setState(() {}),
            );
          }

          final coaches = snapshot.data ?? [];

          if (coaches.isEmpty) {
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
                    label: const Text('Add Coach'),
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
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                return NeumorphicContainer(
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
    showDialog(
      context: context,
      builder: (context) => AddCoachDialog(
        onSubmit: (coachData) async {
          final coachService = ref.read(coachServiceProvider);
          await coachService.createCoach(coachData);
          if (mounted) {
            setState(() {});
          }
        },
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
