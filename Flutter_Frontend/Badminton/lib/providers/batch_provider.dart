import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/batch.dart';
import '../models/student.dart';
import 'service_providers.dart';
import 'dashboard_provider.dart';

part 'batch_provider.g.dart';

/// Provider for batch list state
@riverpod
class BatchList extends _$BatchList {
  @override
  Future<List<Batch>> build() async {
    final batchService = ref.watch(batchServiceProvider);
    final batches = await batchService.getBatches();
    // Sort by ID descending (latest first)
    return batches..sort((a, b) => b.id.compareTo(a.id));
  }

  /// Refresh batch list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final batchService = ref.read(batchServiceProvider);
      final batches = await batchService.getBatches();
      // Sort by ID descending (latest first)
      return batches..sort((a, b) => b.id.compareTo(a.id));
    });
  }

  /// Create a new batch
  Future<void> createBatch(Map<String, dynamic> batchData) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.createBatch(batchData);
      await refresh();
    } catch (e) {
      throw Exception('Failed to create batch: $e');
    }
  }

  /// Update a batch
  Future<void> updateBatch(int id, Map<String, dynamic> batchData) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.updateBatch(id, batchData);
      await refresh();
    } catch (e) {
      throw Exception('Failed to update batch: $e');
    }
  }

  /// Delete a batch (Soft delete - logic varies, we use deactivate for soft delete)
  Future<void> deleteBatch(int id) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.deleteBatch(id);
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete batch: $e');
    }
  }

  /// Deactivate a batch (Soft delete)
  Future<void> deactivateBatch(int id) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.deactivateBatch(id);
      
      ref.invalidate(dashboardStatsProvider);
      await refresh();
    } catch (e) {
      throw Exception('Failed to deactivate batch: $e');
    }
  }

  /// Remove a batch permanently (Hard delete)
  Future<void> removeStudentPermanently(int id) async {
    // Note: I named it removeStudentPermanently in frontend for students, 
    // it should be removeBatchPermanently here for consistency with the backend service.
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.removeBatchPermanently(id);
      
      ref.invalidate(dashboardStatsProvider);
      await refresh();
    } catch (e) {
      throw Exception('Failed to remove batch permanently: $e');
    }
  }

  /// Remove a batch permanently (Hard delete) - Correct name
  Future<void> removeBatchPermanently(int id) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.removeBatchPermanently(id);
      
      ref.invalidate(dashboardStatsProvider);
      await refresh();
    } catch (e) {
      throw Exception('Failed to remove batch permanently: $e');
    }
  }

  /// Enroll a student in a batch and invalidate related providers
  Future<void> enrollStudent(int batchId, int studentId) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.enrollStudent(batchId, studentId);
      
      // Invalidate all related providers
      ref.invalidate(batchStudentsProvider(batchId));
      ref.invalidate(studentBatchesProvider(studentId));
      ref.invalidate(upcomingBatchesProvider);
      ref.invalidate(dashboardStatsProvider);
      
      // Refresh batch list to update enrollment counts
      await refresh();
    } catch (e) {
      throw Exception('Failed to enroll student: $e');
    }
  }

  /// Remove a student from a batch and invalidate related providers
  Future<void> removeStudent(int batchId, int studentId) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.removeStudent(batchId, studentId);
      
      // Invalidate all related providers
      ref.invalidate(batchStudentsProvider(batchId));
      ref.invalidate(studentBatchesProvider(studentId));
      ref.invalidate(upcomingBatchesProvider);
      ref.invalidate(dashboardStatsProvider);
      
      // Refresh batch list to update enrollment counts
      await refresh();
    } catch (e) {
      throw Exception('Failed to remove student: $e');
    }
  }
}

/// Provider for batch students
@riverpod
Future<List<Student>> batchStudents(BatchStudentsRef ref, int batchId) async {
  final batchService = ref.watch(batchServiceProvider);
  return batchService.getBatchStudents(batchId);
}

@riverpod
Future<List<Batch>> studentBatches(StudentBatchesRef ref, int studentId) async {
  final batchService = ref.watch(batchServiceProvider);
  final batches = await batchService.getStudentBatches(studentId);
  // Sort by ID descending (latest first)
  return batches..sort((a, b) => b.id.compareTo(a.id));
}
