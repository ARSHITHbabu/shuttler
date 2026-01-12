import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/attendance.dart';
import '../../models/student.dart';

/// Service for attendance-related API operations
class AttendanceService {
  final ApiService _apiService;

  AttendanceService(this._apiService);

  /// Get attendance records
  Future<List<Attendance>> getAttendance({
    DateTime? date,
    int? batchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Backend uses different endpoint patterns
      if (batchId != null && date != null) {
        // Use: /attendance/batch/{batch_id}/date/{date}
        final dateStr = date.toIso8601String().split('T')[0];
        final response = await _apiService.get(
          '/attendance/batch/$batchId/date/$dateStr',
        );
        
        if (response.data is List) {
          return (response.data as List)
              .map((json) => Attendance.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      }

      // For date range queries, we'll need to fetch all and filter
      // Or use a different endpoint if available
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        ApiEndpoints.attendance,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Attendance.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch attendance: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Mark student attendance
  Future<Attendance> markStudentAttendance({
    required int studentId,
    required int batchId,
    required DateTime date,
    required String status,
    String? remarks,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.attendance,
        data: {
          'student_id': studentId,
          'batch_id': batchId,
          'date': date.toIso8601String().split('T')[0],
          'status': status,
          'remarks': remarks,
        },
      );
      return Attendance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to mark attendance: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Mark multiple students' attendance at once
  Future<void> markMultipleAttendance(List<Map<String, dynamic>> attendanceList) async {
    try {
      // Mark attendance for each student
      for (final attendance in attendanceList) {
        await markStudentAttendance(
          studentId: attendance['student_id'] as int,
          batchId: attendance['batch_id'] as int,
          date: attendance['date'] as DateTime,
          status: attendance['status'] as String,
          remarks: attendance['remarks'] as String?,
        );
      }
    } catch (e) {
      throw Exception('Failed to mark attendance: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get coach attendance records
  Future<List<CoachAttendance>> getCoachAttendance({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date.toIso8601String().split('T')[0];
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        ApiEndpoints.coachAttendance,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => CoachAttendance.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch coach attendance: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Mark coach attendance
  Future<CoachAttendance> markCoachAttendance({
    required int coachId,
    required DateTime date,
    required String status,
    String? remarks,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.coachAttendance,
        data: {
          'coach_id': coachId,
          'date': date.toIso8601String().split('T')[0],
          'status': status,
          'remarks': remarks,
        },
      );
      return CoachAttendance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to mark coach attendance: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get students by batch (for attendance marking)
  Future<List<Student>> getStudentsByBatch(int batchId) async {
    try {
      // Backend uses: GET /batches/{batch_id}/students
      final response = await _apiService.get('/batches/$batchId/students');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Student.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch students: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get today's attendance rate
  Future<double> getTodayAttendanceRate() async {
    try {
      final today = DateTime.now();
      final attendance = await getAttendance(date: today);
      
      if (attendance.isEmpty) return 0.0;
      
      final presentCount = attendance.where((a) => a.status == 'present' || a.status == 'Present').length;
      return (presentCount / attendance.length) * 100;
    } catch (e) {
      // Return 0.0 on error to not break dashboard
      return 0.0;
    }
  }
}
