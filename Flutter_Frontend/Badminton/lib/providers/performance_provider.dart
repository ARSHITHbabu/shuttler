import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/performance.dart';
import 'service_providers.dart';

part 'performance_provider.g.dart';

/// Provider for performance records by student
@riverpod
Future<List<Performance>> performanceByStudent(
  PerformanceByStudentRef ref,
  int studentId, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final performanceService = ref.watch(performanceServiceProvider);
  return performanceService.getPerformanceRecords(
    studentId: studentId,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Provider for performance record by ID
@riverpod
Future<Performance> performanceById(PerformanceByIdRef ref, int id) async {
  final performanceService = ref.watch(performanceServiceProvider);
  return performanceService.getPerformanceById(id);
}

/// Provider for performance trend data
@riverpod
Future<List<Map<String, dynamic>>> performanceTrend(
  PerformanceTrendRef ref,
  int studentId,
  DateTime startDate,
  DateTime endDate,
) async {
  final performanceService = ref.watch(performanceServiceProvider);
  final records = await performanceService.getPerformanceRecords(
    studentId: studentId,
    startDate: startDate,
    endDate: endDate,
  );
  
  // Sort by date
  records.sort((a, b) => a.date.compareTo(b.date));
  
  // Convert to trend data format for charts
  return records.map((record) {
    final Map<String, dynamic> data = {
      'date': record.date,
      'average': record.averageRating,
    };
    // Include individual skill ratings
    record.skills.forEach((key, value) {
      data[key] = value;
    });
    return data;
  }).toList();
}

/// Provider for average performance rating
@riverpod
Future<Map<String, dynamic>> averagePerformance(
  AveragePerformanceRef ref,
  int studentId,
) async {
  final performanceService = ref.watch(performanceServiceProvider);
  final records = await performanceService.getPerformanceRecords(
    studentId: studentId,
  );
  
  if (records.isEmpty) {
    return {
      'average': 0.0,
      'skills': <String, double>{},
      'totalRecords': 0,
    };
  }
  
  Map<String, double> skillSums = {};
  Map<String, int> skillCounts = {};
  
  for (var record in records) {
    record.skills.forEach((skill, rating) {
      skillSums[skill] = (skillSums[skill] ?? 0.0) + rating;
      skillCounts[skill] = (skillCounts[skill] ?? 0) + 1;
    });
  }
  
  Map<String, double> skillAverages = {};
  skillSums.forEach((skill, sum) {
    skillAverages[skill] = sum / skillCounts[skill]!;
  });
  
  final overallAvg = records.map((r) => r.averageRating).reduce((a, b) => a + b) / records.length;
  
  return {
    'average': overallAvg,
    'skills': skillAverages,
    'totalRecords': records.length,
  };
}

/// Provider for latest performance record
@riverpod
Future<Performance?> latestPerformance(LatestPerformanceRef ref, int studentId) async {
  final performanceService = ref.watch(performanceServiceProvider);
  final records = await performanceService.getPerformanceRecords(
    studentId: studentId,
  );
  
  if (records.isEmpty) return null;
  
  // Sort by date descending and return the latest
  records.sort((a, b) => b.date.compareTo(a.date));
  return records.first;
}

/// Provider class for performance CRUD operations
@riverpod
class PerformanceList extends _$PerformanceList {
  @override
  Future<List<Performance>> build({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final performanceService = ref.watch(performanceServiceProvider);
    return performanceService.getPerformanceRecords(
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Create a new performance record
  Future<void> createPerformance(Map<String, dynamic> performanceData) async {
    try {
      final performanceService = ref.read(performanceServiceProvider);
      await performanceService.createPerformance(performanceData);
      
      // Invalidate related providers
      final studentId = performanceData['student_id'] as int?;
      if (studentId != null) {
        ref.invalidate(performanceByStudentProvider(studentId));
        ref.invalidate(averagePerformanceProvider(studentId));
        ref.invalidate(latestPerformanceProvider(studentId));
      }
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to create performance record: $e');
    }
  }

  /// Update a performance record
  Future<void> updatePerformance(int id, Map<String, dynamic> performanceData) async {
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final existing = await performanceService.getPerformanceById(id);
      await performanceService.updatePerformance(id, performanceData);
      
      // Invalidate related providers
      ref.invalidate(performanceByIdProvider(id));
      ref.invalidate(performanceByStudentProvider(existing.studentId));
      ref.invalidate(averagePerformanceProvider(existing.studentId));
      ref.invalidate(latestPerformanceProvider(existing.studentId));
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to update performance record: $e');
    }
  }

  /// Delete a performance record
  Future<void> deletePerformance(int id) async {
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final existing = await performanceService.getPerformanceById(id);
      await performanceService.deletePerformance(id);
      
      // Invalidate related providers
      ref.invalidate(performanceByIdProvider(id));
      ref.invalidate(performanceByStudentProvider(existing.studentId));
      ref.invalidate(averagePerformanceProvider(existing.studentId));
      ref.invalidate(latestPerformanceProvider(existing.studentId));
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete performance record: $e');
    }
  }

  /// Refresh performance list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final performanceService = ref.read(performanceServiceProvider);
      return performanceService.getPerformanceRecords();
    });
  }
}
