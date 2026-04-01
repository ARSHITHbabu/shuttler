import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/coach_provider.dart';
import '../../models/coach_salary.dart';
import '../../models/coach.dart';

/// Coach Salary Screen — shows real salary records fetched from the backend.
/// Coaches can view their payment history month by month.
class CoachSalaryScreen extends ConsumerStatefulWidget {
  const CoachSalaryScreen({super.key});

  @override
  ConsumerState<CoachSalaryScreen> createState() => _CoachSalaryScreenState();
}

class _CoachSalaryScreenState extends ConsumerState<CoachSalaryScreen> {
  List<CoachSalary> _salaries = [];
  Coach? _coach;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  int? _coachId() {
    final auth = ref.read(authProvider).value;
    if (auth is Authenticated) return auth.userId;
    return null;
  }

  Future<void> _load() async {
    final id = _coachId();
    if (id == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final salaryService = ref.read(coachSalaryServiceProvider);

      final salaries = await salaryService.getCoachSalaries(coachId: id);
      salaries.sort((a, b) => b.month.compareTo(a.month)); // newest first

      Coach? coach;
      try {
        coach = await ref.read(coachByIdProvider(id).future);
      } catch (_) {
        // Non-critical — monthly salary stat simply shows "—"
      }

      if (mounted) {
        setState(() {
          _salaries = salaries;
          _coach = coach;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final cardBg = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final accent = isDark ? AppColors.accent : AppColorsLight.accent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        title: Text(
          'Salary Management',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(textPrimary, accent)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    children: [
                      _buildSummaryCard(isDark, textPrimary, textSecondary, accent),
                      const SizedBox(height: AppDimensions.spacingL),
                      Text(
                        'Payment History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      if (_salaries.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No salary records found.',
                              style: TextStyle(color: textSecondary),
                            ),
                          ),
                        )
                      else
                        ..._salaries.map((s) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.spacingS),
                              child: _SalaryRecordCard(
                                salary: s,
                                isDark: isDark,
                              ),
                            )),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(
      bool isDark, Color textPrimary, Color textSecondary, Color accent) {
    final monthlySalary = _coach?.monthlySalary;
    final totalPaid = _salaries.fold<double>(0, (s, r) => s + r.amount);
    final paidCount = _salaries.length;

    // Current month status
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final currentPaid = _salaries.any((s) => s.month == currentMonth);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salary Overview',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Monthly Base',
                  value: monthlySalary != null
                      ? '₹${monthlySalary.toStringAsFixed(0)}'
                      : '—',
                  icon: Icons.account_balance_wallet_outlined,
                  color: accent,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Total Received',
                  value: '₹${totalPaid.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Months Paid',
                  value: '$paidCount',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'This Month',
                  value: currentPaid ? 'Paid' : 'Pending',
                  icon: currentPaid
                      ? Icons.check_circle_outline
                      : Icons.pending_outlined,
                  color: currentPaid ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(Color textPrimary, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppDimensions.spacingM),
            Text(_error!, textAlign: TextAlign.center,
                style: TextStyle(color: textPrimary)),
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _SalaryRecordCard extends StatelessWidget {
  final CoachSalary salary;
  final bool isDark;

  const _SalaryRecordCard({required this.salary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    // Parse month label e.g. "2026-03" → "March 2026"
    String monthLabel = salary.month;
    try {
      final dt = DateFormat('yyyy-MM').parse(salary.month);
      monthLabel = DateFormat('MMMM yyyy').format(dt);
    } catch (_) {}

    final payDate = DateFormat('d MMM yyyy').format(salary.paymentDate);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 22),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          // Month + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(monthLabel,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                const SizedBox(height: 2),
                Text('Paid on $payDate',
                    style: TextStyle(fontSize: 12, color: textSecondary)),
                if (salary.remarks != null && salary.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(salary.remarks!,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          // Amount
          Text(
            '₹${salary.amount.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
        ],
      ),
    );
  }
}
