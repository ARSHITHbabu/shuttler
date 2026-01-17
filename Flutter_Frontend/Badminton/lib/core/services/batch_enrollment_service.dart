import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/batch_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/service_providers.dart';

/// Helper functions for batch enrollment operations with automatic provider invalidation
/// This ensures that all UI components update automatically when enrollment changes
class BatchEnrollmentHelper {
  /// Enroll a student in a batch and invalidate all related providers
  static Future<void> enrollStudent(
    WidgetRef ref,
    int batchId,
    int studentId,
  ) async {
    final batchService = ref.read(batchServiceProvider);
    await batchService.enrollStudent(batchId, studentId);
    _invalidateRelatedProviders(ref, batchId, studentId);
  }

  /// Remove a student from a batch and invalidate all related providers
  static Future<void> removeStudent(
    WidgetRef ref,
    int batchId,
    int studentId,
  ) async {
    final batchService = ref.read(batchServiceProvider);
    await batchService.removeStudent(batchId, studentId);
    _invalidateRelatedProviders(ref, batchId, studentId);
  }

  /// Transfer a student from one batch to another
  static Future<void> transferStudent(
    WidgetRef ref,
    int fromBatchId,
    int toBatchId,
    int studentId,
  ) async {
    final batchService = ref.read(batchServiceProvider);
    // Remove from old batch
    await batchService.removeStudent(fromBatchId, studentId);
    // Add to new batch
    await batchService.enrollStudent(toBatchId, studentId);
    
    // Invalidate providers for both batches
    _invalidateRelatedProviders(ref, fromBatchId, studentId);
    _invalidateRelatedProviders(ref, toBatchId, studentId);
  }

  /// Invalidate all providers that depend on batch-student relationships
  static void _invalidateRelatedProviders(
    WidgetRef ref,
    int batchId,
    int studentId,
  ) {
    // Invalidate batch-specific providers
    ref.invalidate(batchStudentsProvider(batchId));
    ref.invalidate(studentBatchesProvider(studentId));
    
    // Invalidate dashboard providers (student counts, upcoming batches)
    ref.invalidate(upcomingBatchesProvider);
    ref.invalidate(dashboardStatsProvider);
    
    // Invalidate batch list to refresh enrollment counts
    ref.invalidate(batchListProvider);
    
    // Note: Coach stats will be automatically updated when batchStudents is invalidated
    // since coachStatsProvider depends on batchStudentsProvider
  }
}
