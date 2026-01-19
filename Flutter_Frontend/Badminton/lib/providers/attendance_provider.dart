import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/constants/api_endpoints.dart';
import '../models/attendance.dart';
import '../models/student.dart';
import '../models/coach.dart';
import 'service_providers.dart';

part 'attendance_provider.g.dart';

/// Provider for student attendance by date and batch
@riverpod
Future<List<Attendance>> studentAttendance(
  StudentAttendanceRef ref,
  DateTime date,
  int batchId,
) async {
  final attendanceService = ref.watch(attendanceServiceProvider);
  return attendanceService.getAttendance(date: date, batchId: batchId);
}

/// Provider for coach attendance by date
@riverpod
Future<List<CoachAttendance>> coachAttendance(
  CoachAttendanceRef ref,
  DateTime date,
) async {
  final attendanceService = ref.watch(attendanceServiceProvider);
  return attendanceService.getCoachAttendance(date: date);
}

/// Provider for students in a batch (for attendance marking)
@riverpod
Future<List<Student>> batchStudentsForAttendance(
  BatchStudentsForAttendanceRef ref,
  int batchId,
) async {
  final attendanceService = ref.watch(attendanceServiceProvider);
  return attendanceService.getStudentsByBatch(batchId);
}

/// Provider for all coaches (for attendance marking)
@riverpod
Future<List<Coach>> coachesForAttendance(CoachesForAttendanceRef ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get(ApiEndpoints.coaches);
    if (response.data is List) {
      return (response.data as List)
          .map((json) => Coach.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch coaches: ${apiService.getErrorMessage(e)}');
  }
}

/// Provider for attendance records by student
@riverpod
Future<List<Attendance>> attendanceByStudent(
  AttendanceByStudentRef ref,
  int studentId, {
  DateTime? startDate,
  DateTime? endDate,
  int? month,
  int? year,
}) async {
  final apiService = ref.watch(apiServiceProvider);
  
  // Build query parameters
  final queryParams = <String, dynamic>{
    'student_id': studentId,
  };
  
  // Handle month/year filter
  if (month != null && year != null) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0); // Last day of month
    queryParams['start_date'] = start.toIso8601String().split('T')[0];
    queryParams['end_date'] = end.toIso8601String().split('T')[0];
  } else if (startDate != null && endDate != null) {
    queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
    queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
  }
  
  try {
    final response = await apiService.get(
      ApiEndpoints.attendance,
      queryParameters: queryParams,
    );
    
    if (response.data is List) {
      return (response.data as List)
          .map((json) => Attendance.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch attendance: ${apiService.getErrorMessage(e)}');
  }
}
