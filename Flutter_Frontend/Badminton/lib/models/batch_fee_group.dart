import 'batch.dart';
import 'student_with_batch_fee.dart';

/// Model grouping a batch with its student fee information
class BatchFeeGroup {
  final Batch batch;
  final List<StudentWithBatchFee> students;

  BatchFeeGroup({
    required this.batch,
    required this.students,
  });

  // Convenience getters
  String get batchName => batch.batchName;
  int get batchId => batch.id;
  int get totalStudents => students.length;

  /// Check if the batch has any students
  bool get hasStudents => students.isNotEmpty;

  /// Get total pending amount for the batch
  double get totalPending {
    double pending = 0;
    for (final studentFee in students) {
      pending += studentFee.pendingAmount;
    }
    return pending;
  }

  /// Get total paid amount for the batch
  double get totalPaid {
    double paid = 0;
    for (final studentFee in students) {
      paid += studentFee.totalPaid;
    }
    return paid;
  }

  /// Get total overdue amount for the batch
  double get totalOverdue {
    double overdue = 0;
    for (final studentFee in students) {
      if (studentFee.existingFee != null && studentFee.existingFee!.isOverdue) {
        overdue += studentFee.pendingAmount;
      }
    }
    return overdue;
  }

  // Counts
  int get paidCount => students.where((s) => s.existingFee?.status == 'paid').length;

  int get partialCount => students.where((s) =>
    s.existingFee != null && s.existingFee!.status == 'partial'
  ).length;

  int get pendingCount {
    // Both explicitly pending and virtually pending (null fee)
    return students.where((s) =>
      s.existingFee == null ||
      (s.existingFee!.status == 'pending' && !s.existingFee!.isOverdue)
    ).length;
  }

  int get overdueCount => students.where((s) =>
    s.existingFee != null && (s.existingFee!.status == 'overdue' || s.existingFee!.isOverdue)
  ).length;

  // Financials
  double get totalExpectedAmount => totalCollectedAmount + totalPending; // Or sum of batch fees?
  
  double get totalCollectedAmount => totalPaid;
}
