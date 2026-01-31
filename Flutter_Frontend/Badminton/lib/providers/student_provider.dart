import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student.dart';
import '../models/owner.dart';
import '../models/coach.dart';
import '../models/schedule.dart';
import '../utils/batch_time_utils.dart';
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
        (student.guardianName != null &&
            student.guardianName!.toLowerCase().contains(lowerQuery));
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
Future<StudentDashboardData> studentDashboard(
  StudentDashboardRef ref,
  int studentId,
) async {
  // Get student info
  final student = await ref.watch(studentByIdProvider(studentId).future);

  // Get student batches
  final batches = await ref.watch(studentBatchesProvider(studentId).future);

  // Calculate attendance rate
  final attendanceRecords = await ref.watch(
    attendanceByStudentProvider(studentId).future,
  );
  double attendanceRate = 0.0;
  if (attendanceRecords.isNotEmpty) {
    final present = attendanceRecords
        .where((r) => r.status.toLowerCase() == 'present')
        .length;
    attendanceRate = (present / attendanceRecords.length) * 100;
  }

  // Get overall performance average
  final overallPerformance = await ref.watch(
    averagePerformanceProvider(studentId).future,
  );
  double performanceScore = overallPerformance['average'] ?? 0.0;

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

  // Get upcoming sessions - work directly with batches (like owner/coach dashboard)
  final now = DateTime.now();
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final todayDayName = dayNames[now.weekday - 1];
  final upcomingSessions = <Map<String, dynamic>>[];

  // Parse batch timing to extract start/end times
  String? parseBatchStartTime(String timing) {
    try {
      final parts = timing.split(' - ');
      if (parts.length == 2) return parts[0].trim();
    } catch (_) {}
    return null;
  }

  String? parseBatchEndTime(String timing) {
    try {
      final parts = timing.split(' - ');
      if (parts.length == 2) return parts[1].trim();
    } catch (_) {}
    return null;
  }

  // Get today's sessions and future sessions (next 7 days)
  // Only add ONE session per batch - either today (if upcoming) OR next future occurrence
  for (var batch in batches) {
    bool batchAdded = false;

    // Check if batch runs today
    final runsToday =
        batch.period.toLowerCase() == 'daily' ||
        batch.days.contains(todayDayName);

    if (runsToday && BatchTimeUtils.isBatchUpcoming(batch)) {
      // Batch runs today and is upcoming - add it
      final startTimeStr = parseBatchStartTime(batch.timing);
      final endTimeStr = parseBatchEndTime(batch.timing);
      final timeStr = startTimeStr != null && endTimeStr != null
          ? '$startTimeStr - $endTimeStr'
          : (startTimeStr ?? batch.timing);

      upcomingSessions.add({
        'batch_name': batch.name,
        'time': timeStr,
        'location': batch.location ?? '',
        'date': DateTime(now.year, now.month, now.day).toIso8601String(),
      });
      batchAdded = true; // Mark as added, skip future days for this batch
    }

    // Only check future days if batch wasn't added for today
    if (!batchAdded) {
      // Get future sessions (next 7 days)
      for (int i = 1; i <= 7 && upcomingSessions.length < 5; i++) {
        final checkDate = now.add(Duration(days: i));
        final checkDayName = dayNames[checkDate.weekday - 1];

        // Check if batch runs on this future day
        final runsOnDay =
            batch.period.toLowerCase() == 'daily' ||
            batch.days.contains(checkDayName);

        if (runsOnDay) {
          final startTimeStr = parseBatchStartTime(batch.timing);
          final endTimeStr = parseBatchEndTime(batch.timing);
          final timeStr = startTimeStr != null && endTimeStr != null
              ? '$startTimeStr - $endTimeStr'
              : (startTimeStr ?? batch.timing);

          final dateStr = DateTime(
            checkDate.year,
            checkDate.month,
            checkDate.day,
          ).toIso8601String();
          upcomingSessions.add({
            'batch_name': batch.name,
            'time': timeStr,
            'location': batch.location ?? '',
            'date': dateStr,
          });
          break; // Only add one future session per batch
        }
      }
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
Future<List<Schedule>> studentSchedules(
  StudentSchedulesRef ref,
  int studentId,
) async {
  final scheduleService = ref.watch(scheduleServiceProvider);
  final batches = await ref.watch(studentBatchesProvider(studentId).future);

  List<Schedule> allSchedules = [];

  for (var batch in batches) {
    try {
      final batchSchedules = await scheduleService.getSchedules(
        batchId: batch.id,
      );
      // Add batch name to schedules for display
      final schedulesWithBatchName = batchSchedules.map((schedule) {
        return schedule.copyWith(batchName: batch.name, batchId: batch.id);
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

/// Provider for the active owner
@riverpod
Future<Owner?> activeOwner(ActiveOwnerRef ref) async {
  final ownerService = ref.watch(ownerServiceProvider);
  final owners = await ownerService.getOwners();
  if (owners.isNotEmpty) {
    return owners.first; // Return the first owner for now
  }
  return null;
}

/// Provider for student's coaches
@riverpod
Future<List<Coach>> studentCoaches(StudentCoachesRef ref, int studentId) async {
  final coachService = ref.watch(coachServiceProvider);
  // Get student batches to find assigned coaches
  final batches = await ref.watch(studentBatchesProvider(studentId).future);
  
  final Set<int> coachIds = {};
  for (final batch in batches) {
    coachIds.addAll(batch.assignedCoachIds);
    // Backward compatibility
    if (batch.assignedCoachIds.isEmpty && batch.assignedCoachId != null) {
      coachIds.add(batch.assignedCoachId!);
    }
  }

  if (coachIds.isEmpty) {
    return [];
  }

  // Fetch all coaches and filter
  // This is more efficient than making N API calls if N is small, 
  // but for larger systems we should have a bulk fetch API.
  final allCoaches = await coachService.getCoaches();
  return allCoaches.where((c) => coachIds.contains(c.id)).toList();
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
