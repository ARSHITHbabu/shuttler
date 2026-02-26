import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/success_snackbar.dart';
import '../../../widgets/forms/add_salary_dialog.dart';
import '../../../providers/coach_salary_provider.dart';
import '../../../providers/service_providers.dart';

class CoachSalaryTab extends ConsumerStatefulWidget {
  const CoachSalaryTab({super.key});

  @override
  ConsumerState<CoachSalaryTab> createState() => _CoachSalaryTabState();
}

class _CoachSalaryTabState extends ConsumerState<CoachSalaryTab> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
  }

  String get _formattedMonth => DateFormat('yyyy-MM').format(_selectedMonth);
  String get _displayMonth => DateFormat('MMMM yyyy').format(_selectedMonth);

  double _calculateSuggestedSalary(CoachSalaryState state) {
    if (state.coach.monthlySalary == null) return 0.0;
    if (state.coach.joiningDate == null) return state.coach.monthlySalary!;

    final joiningDate = state.coach.joiningDate!;
    
    // If coach joined after the selected month, suggested is 0
    if (joiningDate.year > _selectedMonth.year || 
        (joiningDate.year == _selectedMonth.year && joiningDate.month > _selectedMonth.month)) {
      return 0.0;
    }

    // If coach joined in the selected month, prorate
    if (joiningDate.year == _selectedMonth.year && joiningDate.month == _selectedMonth.month) {
      final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
      final daysWorked = daysInMonth - joiningDate.day + 1;
      return (state.coach.monthlySalary! / daysInMonth) * daysWorked;
    }

    // Otherwise, full salary
    return state.coach.monthlySalary!;
  }

  void _showAddSalaryDialog(CoachSalaryState state) {
    final suggestedAmount = _calculateSuggestedSalary(state);
    
    showDialog(
      context: context,
      builder: (context) => AddSalaryDialog(
        coachId: state.coach.id,
        coachName: state.coach.name,
        month: _formattedMonth,
        initialAmount: suggestedAmount,
        onSubmit: (data) async {
          try {
            final service = ref.read(coachSalaryServiceProvider);
            await service.createCoachSalary(data);
            
            ref.invalidate(coachMonthlySummaryProvider(_formattedMonth));
            
            if (mounted) {
              Navigator.pop(context);
              SuccessSnackbar.show(context, 'Salary recorded successfully');
            }
          } catch (e) {
            if (mounted) {
              SuccessSnackbar.showError(context, 'Failed to record salary: ${e.toString()}');
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(coachMonthlySummaryProvider(_formattedMonth));

    return Column(
      children: [
        // Month Selector Header
        Padding(
          padding: EdgeInsets.all(AppDimensions.getScreenPadding(context)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  _displayMonth,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
        ),

        summaryAsync.when(
          loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Expanded(child: Center(child: Text('Error: $err'))),
          data: (summary) {
            final totalPaid = summary
                .where((s) => s.status == 'paid')
                .fold(0.0, (sum, s) => sum + (s.salary?.amount ?? 0));
            final pendingCount = summary.where((s) => s.status == 'pending').length;

            return Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.getScreenPadding(context)),
                child: Column(
                  children: [
                    // Dashboard Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Paid',
                            '\$${totalPaid.toStringAsFixed(0)}',
                            Icons.payments,
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            pendingCount.toString(),
                            Icons.pending_actions,
                            AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingL),

                    if (summary.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Text('No active coaches found.', style: TextStyle(color: AppColors.textSecondary)),
                      ))
                    else
                      ...summary.map((state) => _buildCoachCard(state)),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachCard(CoachSalaryState state) {
    final isPaid = state.status == 'paid';
    final suggestedAmount = _calculateSuggestedSalary(state);
    
    // Hide coaches who haven't joined yet
    if (suggestedAmount == 0 && !isPaid) return const SizedBox.shrink();

    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              state.coach.name[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.coach.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (isPaid)
                  Text(
                    'Paid on: ${DateFormat('dd MMM').format(state.salary!.paymentDate)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Text(
                    'Base: \$${state.coach.monthlySalary?.toStringAsFixed(0) ?? "0"}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isPaid) ...[
                Text(
                  '\$${state.salary!.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                _buildStatusBadge('PAID', AppColors.success),
              ] else ...[
                ElevatedButton(
                  onPressed: () => _showAddSalaryDialog(state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusS)),
                  ),
                  child: const Text('Pay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
