import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/coach_salary.dart';
import '../models/coach.dart';
import 'service_providers.dart';
import 'coach_provider.dart';

part 'coach_salary_provider.g.dart';

@riverpod
Future<List<CoachSalary>> coachSalaryList(CoachSalaryListRef ref, {String? month}) async {
  final service = ref.watch(coachSalaryServiceProvider);
  return service.getCoachSalaries(month: month);
}

@riverpod
Future<List<CoachSalaryState>> coachMonthlySummary(CoachMonthlySummaryRef ref, String month) async {
  // 1. Get all active coaches
  final coaches = await ref.watch(coachListProvider.future);
  
  // 2. Get salaries for the month
  final salaries = await ref.watch(coachSalaryListProvider(month: month).future);
  
  // 3. Merge data
  final List<CoachSalaryState> summary = [];
  
  for (final coach in coaches) {
    // Find matching salary record
    final salary = salaries.firstWhere(
      (s) => s.coachId == coach.id,
      orElse: () => CoachSalary(
        id: -1, // Virtual ID
        coachId: coach.id,
        coachName: coach.name,
        amount: 0,
        paymentDate: DateTime.now(),
        month: month,
      ),
    );
    
    summary.add(CoachSalaryState(
      coach: coach,
      salary: salary.id != -1 ? salary : null,
      status: salary.id != -1 ? 'paid' : 'pending',
    ));
  }
  
  return summary;
}

// Helper class to hold merged data
class CoachSalaryState {
  final Coach coach;
  final CoachSalary? salary;
  final String status; // 'paid', 'pending'

  CoachSalaryState({
    required this.coach,
    this.salary,
    required this.status,
  });
}
