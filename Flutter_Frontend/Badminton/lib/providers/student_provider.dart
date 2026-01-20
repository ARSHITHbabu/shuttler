import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student.dart';
import '../models/schedule.dart';
import 'service_providers.dart';
import 'batch_provider.dart';
import 'dashboard_provider.dart';
import 'attendance_provider.dart';
import 'performance_provider.dart';
import 'bmi_provider.dart';
import 'fee_provider.dart';

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

/// Provider for student dashboard data (stats and upcoming sessions)
@riverpod
Future<StudentDashboardData> studentDashboard(StudentDashboardRef ref, int studentId) async {
  // Get student info
  final student = await ref.watch(studentByIdProvider(studentId).future);
  
  // Get student batches
  final batches = await ref.watch(studentBatchesProvider(studentId).future);
  
  // Calculate attendance rate
  final attendanceRecords = await ref.watch(attendanceByStudentProvider(studentId).future);
  double attendanceRate = 0.0;
  if (attendanceRecords.isNotEmpty) {
    final present = attendanceRecords.where((r) => r.status.toLowerCase() == 'present').length;
    attendanceRate = (present / attendanceRecords.length) * 100;
  }
  
  // Get latest performance
  final performanceRecords = await ref.watch(performanceByStudentProvider(studentId).future);
  double performanceScore = 0.0;
  if (performanceRecords.isNotEmpty) {
    performanceRecords.sort((a, b) => b.date.compareTo(a.date));
    performanceScore = performanceRecords.first.averageRating;
  }
  
  // Get latest BMI
  final bmiRecords = await ref.watch(bmiByStudentProvider(studentId).future);
  String bmiStatus = 'N/A';
  if (bmiRecords.isNotEmpty) {
    bmiRecords.sort((a, b) => b.date.compareTo(a.date));
    final latestBmi = bmiRecords.first.bmi;
    if (latestBmi < 18.5) {
      bmiStatus = 'Underweight';
    } else if (latestBmi < 25) {
      bmiStatus = 'Normal';
    } else if (latestBmi < 30) {
      bmiStatus = 'Overweight';
    } else {
      bmiStatus = 'Obese';
    }
  }
  
  // Get fee status
  final fees = await ref.watch(feeListProvider(studentId: studentId).future);
  String feeStatus = 'N/A';
  if (fees.isNotEmpty) {
    final pendingFees = fees.where((f) => f.status != 'paid').length;
    if (pendingFees == 0) {
      feeStatus = 'All Paid';
    } else {
      feeStatus = '$pendingFees Pending';
    }
  }
  
  // Get upcoming sessions
  final scheduleService = ref.watch(scheduleServiceProvider);
  final now = DateTime.now();
  final upcomingSessions = <Map<String, dynamic>>[];
  
  for (var batch in batches) {
    try {
      final schedules = await scheduleService.getSchedules(batchId: batch.id);
      for (var schedule in schedules) {
        if (schedule.date.isAfter(now)) {
          upcomingSessions.add({
            'batch_name': batch.name,
            'time': schedule.startTime ?? '',
            'location': schedule.location ?? '',
            'date': schedule.date.toIso8601String(),
          });
        }
      }
    } catch (e) {
      // Skip if error
    }
  }
  
  // Sort by date and limit to 5
  upcomingSessions.sort((a, b) {
    try {
      final dateA = DateTime.parse(a['date'] as String);
      final dateB = DateTime.parse(b['date'] as String);
      return dateA.compareTo(dateB);
    } catch (_) {
      return 0;
    }
  });
  
  return StudentDashboardData(
    studentName: student.name,
    attendanceRate: attendanceRate,
    performanceScore: performanceScore,
    bmiStatus: bmiStatus,
    feeStatus: feeStatus,
    upcomingSessions: upcomingSessions.take(5).toList(),
  );
}

/// Provider for student schedules (all schedules for batches student is enrolled in)
@riverpod
Future<List<Schedule>> studentSchedules(StudentSchedulesRef ref, int studentId) async {
  final scheduleService = ref.watch(scheduleServiceProvider);
  final batches = await ref.watch(studentBatchesProvider(studentId).future);
  
  List<Schedule> allSchedules = [];
  
  for (var batch in batches) {
    try {
      final batchSchedules = await scheduleService.getSchedules(batchId: batch.id);
      // Add batch name to schedules for display
      final schedulesWithBatchName = batchSchedules.map((schedule) {
        return schedule.copyWith(
          batchName: batch.name,
          batchId: batch.id,
        );
      }).toList();
      allSchedules.addAll(schedulesWithBatchName);
    } catch (e) {
      // Skip if error fetching schedules for this batch
      continue;
    }
  }
  
  // Sort by date (newest first)
  allSchedules.sort((a, b) => b.date.compareTo(a.date));
  
  return allSchedules;
}

/// Student dashboard data class
class StudentDashboardData {
  final String studentName;
  final double attendanceRate;
  final double performanceScore;
  final String bmiStatus;
  final String feeStatus;
  final List<Map<String, dynamic>> upcomingSessions;
  
  StudentDashboardData({
    required this.studentName,
    required this.attendanceRate,
    required this.performanceScore,
    required this.bmiStatus,
    required this.feeStatus,
    required this.upcomingSessions,
  });
}
