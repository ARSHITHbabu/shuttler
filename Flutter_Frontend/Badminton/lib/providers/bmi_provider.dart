import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/bmi_record.dart';
import 'service_providers.dart';

part 'bmi_provider.g.dart';

/// Provider for BMI records by student
@riverpod
Future<List<BMIRecord>> bmiByStudent(
  BmiByStudentRef ref,
  int studentId, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final bmiService = ref.watch(bmiServiceProvider);
  return bmiService.getBMIRecords(
    studentId: studentId,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Provider for BMI record by ID
@riverpod
Future<BMIRecord> bmiById(BmiByIdRef ref, int id) async {
  final bmiService = ref.watch(bmiServiceProvider);
  return bmiService.getBMIRecordById(id);
}

/// Provider for latest BMI record
@riverpod
Future<BMIRecord?> latestBmi(LatestBmiRef ref, int studentId) async {
  final bmiService = ref.watch(bmiServiceProvider);
  final records = await bmiService.getBMIRecords(studentId: studentId);
  
  if (records.isEmpty) return null;
  
  // Sort by date descending and return the latest
  records.sort((a, b) => b.date.compareTo(a.date));
  return records.first;
}

/// Provider for BMI trend data
@riverpod
Future<List<Map<String, dynamic>>> bmiTrend(
  BmiTrendRef ref,
  int studentId,
) async {
  final bmiService = ref.watch(bmiServiceProvider);
  final records = await bmiService.getBMIRecords(studentId: studentId);
  
  // Sort by date
  records.sort((a, b) => a.date.compareTo(b.date));
  
  // Convert to trend data format for charts
  return records.map((record) {
    return {
      'date': record.date,
      'bmi': record.bmi,
      'height': record.height,
      'weight': record.weight,
      'healthStatus': record.healthStatus,
    };
  }).toList();
}

/// Provider class for BMI CRUD operations
@riverpod
class BmiList extends _$BmiList {
  @override
  Future<List<BMIRecord>> build({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final bmiService = ref.watch(bmiServiceProvider);
    return bmiService.getBMIRecords(
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Create a new BMI record
  Future<void> createBmiRecord(Map<String, dynamic> bmiData) async {
    try {
      final bmiService = ref.read(bmiServiceProvider);
      await bmiService.createBMIRecord(bmiData);
      
      // Invalidate related providers
      final studentId = bmiData['student_id'] as int?;
      if (studentId != null) {
        ref.invalidate(bmiByStudentProvider(studentId));
        ref.invalidate(latestBmiProvider(studentId));
        ref.invalidate(bmiTrendProvider(studentId));
      }
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to create BMI record: $e');
    }
  }

  /// Update a BMI record
  Future<void> updateBmiRecord(int id, Map<String, dynamic> bmiData) async {
    try {
      final bmiService = ref.read(bmiServiceProvider);
      final existing = await bmiService.getBMIRecordById(id);
      await bmiService.updateBMIRecord(id, bmiData);
      
      // Invalidate related providers
      ref.invalidate(bmiByIdProvider(id));
      ref.invalidate(bmiByStudentProvider(existing.studentId));
      ref.invalidate(latestBmiProvider(existing.studentId));
      ref.invalidate(bmiTrendProvider(existing.studentId));
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to update BMI record: $e');
    }
  }

  /// Delete a BMI record
  Future<void> deleteBmiRecord(int id) async {
    try {
      final bmiService = ref.read(bmiServiceProvider);
      final existing = await bmiService.getBMIRecordById(id);
      await bmiService.deleteBMIRecord(id);
      
      // Invalidate related providers
      ref.invalidate(bmiByIdProvider(id));
      ref.invalidate(bmiByStudentProvider(existing.studentId));
      ref.invalidate(latestBmiProvider(existing.studentId));
      ref.invalidate(bmiTrendProvider(existing.studentId));
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete BMI record: $e');
    }
  }

  /// Refresh BMI list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bmiService = ref.read(bmiServiceProvider);
      return bmiService.getBMIRecords();
    });
  }
}
