import 'student.dart';
import 'batch.dart';
import 'fee.dart';

/// Model combining student, batch, and fee information
/// Used to display all students enrolled in batches with their fee status
class StudentWithBatchFee {
  final Student student;
  final Batch batch;
  final double batchFeeAmount; // Fee amount from batch.fees
  final Fee? existingFee; // null if fee doesn't exist yet

  StudentWithBatchFee({
    required this.student,
    required this.batch,
    required this.batchFeeAmount,
    this.existingFee,
  });

  /// Check if fee exists for this student-batch combination
  bool get hasFee => existingFee != null;

  /// Get fee status (or 'not_created' if fee doesn't exist)
  String get feeStatus {
    if (existingFee == null) return 'not_created';
    return existingFee!.status;
  }

  /// Get pending amount (0 if fee doesn't exist, or existingFee.pendingAmount)
  double get pendingAmount {
    if (existingFee == null) return batchFeeAmount;
    return existingFee!.pendingAmount;
  }

  /// Get total paid amount
  double get totalPaid {
    if (existingFee == null) return 0.0;
    return existingFee!.totalPaid;
  }
}
