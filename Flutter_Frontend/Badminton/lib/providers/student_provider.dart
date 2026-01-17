import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student.dart';
import 'service_providers.dart';
import 'batch_provider.dart';
import 'dashboard_provider.dart';

part 'student_provider.g.dart';

/// Provider for student list state
@riverpod
class StudentList extends _$StudentList {
  @override
  Future<List<Student>> build() async {
    final studentService = ref.watch(studentServiceProvider);
    return studentService.getStudents();
  }

  /// Refresh student list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final studentService = ref.read(studentServiceProvider);
      return studentService.getStudents();
    });
  }

  /// Create a new student
  Future<void> createStudent(Map<String, dynamic> studentData) async {
    try {
      final studentService = ref.read(studentServiceProvider);
      await studentService.createStudent(studentData);
      
      // Invalidate related providers
      ref.invalidate(dashboardStatsProvider);
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  /// Update a student
  Future<void> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      final studentService = ref.read(studentServiceProvider);
      await studentService.updateStudent(id, studentData);
      
      // Invalidate related providers
      ref.invalidate(studentByIdProvider(id));
      ref.invalidate(dashboardStatsProvider);
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  /// Delete a student
  Future<void> deleteStudent(int id) async {
    try {
      final studentService = ref.read(studentServiceProvider);
      await studentService.deleteStudent(id);
      
      // Invalidate related providers
      ref.invalidate(studentByIdProvider(id));
      ref.invalidate(studentBatchesProvider(id));
      ref.invalidate(dashboardStatsProvider);
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }
}

/// Provider for student by ID
@riverpod
Future<Student> studentById(StudentByIdRef ref, int id) async {
  final studentService = ref.watch(studentServiceProvider);
  return studentService.getStudentById(id);
}

/// Provider for student search
@riverpod
Future<List<Student>> studentSearch(StudentSearchRef ref, String query) async {
  final studentService = ref.watch(studentServiceProvider);
  final allStudents = await studentService.getStudents();
  
  if (query.isEmpty) {
    return allStudents;
  }
  
  final lowerQuery = query.toLowerCase();
  return allStudents.where((student) {
    return student.name.toLowerCase().contains(lowerQuery) ||
        student.email.toLowerCase().contains(lowerQuery) ||
        student.phone.contains(query) ||
        (student.guardianName != null && student.guardianName!.toLowerCase().contains(lowerQuery));
  }).toList();
}

/// Provider for students by batch
@riverpod
Future<List<Student>> studentByBatch(StudentByBatchRef ref, int batchId) async {
  final batchService = ref.watch(batchServiceProvider);
  return batchService.getBatchStudents(batchId);
}

/// Provider for student statistics
@riverpod
Future<Map<String, dynamic>> studentStats(StudentStatsRef ref) async {
  final studentService = ref.watch(studentServiceProvider);
  final students = await studentService.getStudents();
  
  return {
    'total': students.length,
    'active': students.where((s) => s.status == 'active').length,
    'inactive': students.where((s) => s.status != 'active').length,
  };
}
