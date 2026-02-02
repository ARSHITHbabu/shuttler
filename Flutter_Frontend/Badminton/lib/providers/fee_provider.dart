import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/fee.dart';
import '../models/student_with_batch_fee.dart';
import '../models/student.dart';
import '../models/batch.dart';
import '../models/batch_fee_group.dart';
import 'service_providers.dart';
import 'dashboard_provider.dart';
import 'batch_provider.dart';

part 'fee_provider.g.dart';

/// Provider for fee list state
@riverpod
class FeeList extends _$FeeList {
  @override
  Future<List<Fee>> build({
    int? studentId,
    int? batchId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final feeService = ref.watch(feeServiceProvider);
    return feeService.getFees(
      studentId: studentId,
      batchId: batchId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Refresh fee list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final feeService = ref.read(feeServiceProvider);
      return feeService.getFees();
    });
  }

  /// Create a new fee record
  Future<void> createFee(Map<String, dynamic> feeData) async {
    try {
      final feeService = ref.read(feeServiceProvider);
      await feeService.createFee(feeData);
      
      // Invalidate related providers
      ref.invalidate(dashboardStatsProvider);
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to create fee: $e');
    }
  }

  /// Update a fee record
  Future<void> updateFee(int id, Map<String, dynamic> feeData) async {
    try {
      final feeService = ref.read(feeServiceProvider);
      await feeService.updateFee(id, feeData);
      
      // Invalidate related providers
      ref.invalidate(feeByIdProvider(id));
      ref.invalidate(dashboardStatsProvider);
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to update fee: $e');
    }
  }

  /// Record payment for a fee
  Future<void> recordPayment({
    required int feeId,
    required String paymentMethod,
    DateTime? paidDate,
    String? remarks,
  }) async {
    try {
      final feeService = ref.read(feeServiceProvider);
      await feeService.recordPayment(
        feeId: feeId,
        paymentMethod: paymentMethod,
        paidDate: paidDate,
        remarks: remarks,
      );
      
      // Invalidate related providers
      ref.invalidate(feeByIdProvider(feeId));
      ref.invalidate(dashboardStatsProvider);
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to record payment: $e');
    }
  }
}

/// Provider for fee by ID
@riverpod
Future<Fee> feeById(FeeByIdRef ref, int id) async {
  final feeService = ref.watch(feeServiceProvider);
  return feeService.getFeeById(id);
}

/// Provider for fees by student
@riverpod
Future<List<Fee>> feeByStudent(FeeByStudentRef ref, int studentId) async {
  final feeService = ref.watch(feeServiceProvider);
  return feeService.getFees(studentId: studentId);
}

/// Provider for fee statistics
@riverpod
Future<Map<String, dynamic>> feeStats(FeeStatsRef ref) async {
  final feeService = ref.watch(feeServiceProvider);
  final allFees = await feeService.getFees();
  
  final total = allFees.fold<double>(0.0, (sum, fee) => sum + fee.amount);
  final totalPaid = allFees.fold<double>(0.0, (sum, fee) => sum + fee.totalPaid);
  final totalPending = allFees.fold<double>(0.0, (sum, fee) => sum + fee.pendingAmount);
  
  final paidCount = allFees.where((f) => f.status == 'paid').length;
  final pendingCount = allFees.where((f) => f.status == 'pending').length;
  final overdueCount = allFees.where((f) => f.status == 'overdue' || f.isOverdue).length;
  
  return {
    'total': total,
    'totalPaid': totalPaid,
    'totalPending': totalPending,
    'paidCount': paidCount,
    'pendingCount': pendingCount,
    'overdueCount': overdueCount,
  };
}

/// Provider for pending fees
@riverpod
Future<List<Fee>> pendingFees(PendingFeesRef ref) async {
  final feeService = ref.watch(feeServiceProvider);
  return feeService.getFees(status: 'pending');
}

/// Provider for overdue fees
@riverpod
Future<List<Fee>> overdueFees(OverdueFeesRef ref) async {
  final feeService = ref.watch(feeServiceProvider);
  final allFees = await feeService.getFees();
  return allFees.where((fee) => fee.status == 'overdue' || fee.isOverdue).toList();
}

/// Provider for all students with their batch enrollments and fee status
/// Returns students grouped by batch with their fee information
@riverpod
Future<Map<int, BatchFeeGroup>> studentsWithBatchFees(
  StudentsWithBatchFeesRef ref,
) async {
  final batchService = ref.watch(batchServiceProvider);
  final feeService = ref.watch(feeServiceProvider);
  
  // Get all batches
  final batches = await batchService.getBatches();
  
  // Get all existing fees
  final allFees = await feeService.getFees();
  
  // Map to store batchId -> BatchFeeGroup
  final Map<int, BatchFeeGroup> result = {};
  
  // For each batch, get enrolled students and match with fees
  for (final batch in batches) {
    try {
      // Get students enrolled in this batch
      final students = await batchService.getBatchStudents(batch.id);
      
      // Parse batch fee amount (handle string format like "5000" or "$5000")
      double batchFeeAmount = 0.0;
      try {
        final feeString = batch.fees.replaceAll(RegExp(r'[\$,\s]'), '');
        batchFeeAmount = double.parse(feeString);
      } catch (e) {
        // If parsing fails, default to 0
        batchFeeAmount = 0.0;
      }
      
      // Create StudentWithBatchFee for each student
      final studentFeeList = students.map((student) {
        // Find existing fee for this student-batch combination
        Fee? existingFee;
        try {
          existingFee = allFees.firstWhere(
            (fee) => fee.studentId == student.id && fee.batchId == batch.id,
          );
        } catch (e) {
          // No fee found for this student-batch combination
          existingFee = null;
        }
        
        return StudentWithBatchFee(
          student: student,
          batch: batch,
          batchFeeAmount: batchFeeAmount,
          existingFee: existingFee,
        );
      }).toList();
      
      // Always add the batch to the result, even if studentFeeList is empty
      result[batch.id] = BatchFeeGroup(
        batch: batch,
        students: studentFeeList,
      );
    } catch (e) {
      // Skip batch if there's an error fetching students
      continue;
    }
  }
  
  return result;
}
