import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/batch.dart';
import '../models/student.dart';
import 'service_providers.dart';

part 'batch_provider.g.dart';

/// Provider for batch list state
@riverpod
class BatchList extends _$BatchList {
  @override
  Future<List<Batch>> build() async {
    final batchService = ref.watch(batchServiceProvider);
    return batchService.getBatches();
  }

  /// Refresh batch list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final batchService = ref.read(batchServiceProvider);
      return batchService.getBatches();
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

  /// Delete a batch
  Future<void> deleteBatch(int id) async {
    try {
      final batchService = ref.read(batchServiceProvider);
      await batchService.deleteBatch(id);
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete batch: $e');
    }
  }
}

/// Provider for batch students
@riverpod
Future<List<Student>> batchStudents(BatchStudentsRef ref, int batchId) async {
  final batchService = ref.watch(batchServiceProvider);
  return batchService.getBatchStudents(batchId);
}
