import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'batch_service.dart';
import 'attendance_service.dart';
import 'fee_service.dart';
import '../../models/batch.dart';
import '../../models/batch_attendance.dart';
import '../../utils/batch_time_utils.dart';

/// Dashboard statistics model
class DashboardStats {
  final int totalStudents;
  final int totalCoaches;
  final int activeBatches;
  final double pendingFees;
  final double todayAttendanceRate;

  DashboardStats({
    required this.totalStudents,
    required this.totalCoaches,
    required this.activeBatches,
    required this.pendingFees,
    required this.todayAttendanceRate,
  });
}

/// Service for dashboard-related API operations
class DashboardService {
  final ApiService _apiService;
  final BatchService _batchService;
  final AttendanceService _attendanceService;
  final FeeService _feeService;

  DashboardService(
    this._apiService,
    this._batchService,
    this._attendanceService,
    this._feeService,
  );

  /// Get dashboard statistics
  Future<DashboardStats> getDashboardStats() async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _getTotalStudents(),
        _getTotalCoaches(),
        _getActiveBatches(),
        _feeService.getTotalPendingFees(),
        _attendanceService.getTodayAttendanceRate(),
      ]);

      return DashboardStats(
        totalStudents: results[0] as int,
        totalCoaches: results[1] as int,
        activeBatches: results[2] as int,
        pendingFees: results[3] as double,
        todayAttendanceRate: results[4] as double,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get total number of students
  Future<int> _getTotalStudents() async {
    try {
      final response = await _apiService.get(ApiEndpoints.students);
      if (response.data is List) {
        return (response.data as List).length;
      }
      return 0;
    } catch (e) {
      return 0; // Return 0 on error to not break dashboard
    }
  }

  /// Get total number of coaches
  Future<int> _getTotalCoaches() async {
    try {
      final response = await _apiService.get(ApiEndpoints.coaches);
      if (response.data is List) {
        return (response.data as List).length;
      }
      return 0;
    } catch (e) {
      return 0; // Return 0 on error to not break dashboard
    }
  }

  /// Get number of active batches
  Future<int> _getActiveBatches() async {
    try {
      final batches = await _batchService.getBatches();
      return batches.where((b) => b.status.toLowerCase() == 'active').length;
    } catch (e) {
      return 0; // Return 0 on error to not break dashboard
    }
  }

  /// Get finished batches for today with their attendance rates (students only)
  Future<List<BatchAttendance>> getFinishedBatchesWithAttendance() async {
    try {
      final today = DateTime.now();
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final todayDayName = dayNames[today.weekday - 1];
      
      // Get all batches
      final allBatches = await _batchService.getBatches();
      
      // Filter batches that run today and have finished
      final finishedBatches = allBatches.where((batch) {
        if (!_batchRunsOnDay(batch, todayDayName)) return false;
        return BatchTimeUtils.isBatchFinished(batch);
      }).toList();

      // Calculate attendance rate for each finished batch
      final batchAttendanceList = <BatchAttendance>[];
      
      for (final batch in finishedBatches) {
        try {
          final attendance = await _attendanceService.getAttendance(
            date: today,
            batchId: batch.id,
          );
          
          // Filter only student attendance (exclude coaches)
          final studentAttendance = attendance.where((a) {
            // Assuming attendance records have student_id, not coach_id
            // This filters out coach attendance if any
            return true; // All attendance from /attendance/ endpoint should be student attendance
          }).toList();
          
          if (studentAttendance.isEmpty) {
            // No attendance marked yet, skip or show 0%
            continue;
          }
          
          final presentCount = studentAttendance
              .where((a) => a.status.toLowerCase() == 'present')
              .length;
          final attendanceRate = (presentCount / studentAttendance.length) * 100;
          
          batchAttendanceList.add(BatchAttendance(
            batchId: batch.id,
            batchName: batch.batchName,
            timing: batch.timing,
            attendanceRate: attendanceRate,
          ));
        } catch (e) {
          // Skip batch if error fetching attendance
          continue;
        }
      }
      
      return batchAttendanceList;
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  /// Check if batch runs on a specific day
  /// Handles "Daily" period and regular day lists
  bool _batchRunsOnDay(Batch batch, String dayName) {
    // Check if batch runs daily
    if (batch.period.toLowerCase() == 'daily') {
      return true;
    }
    // Check if batch runs on the specific day
    return batch.days.contains(dayName);
  }

  /// Get student count for a batch
  /// Note: This method is used by the dashboard. For reactive updates,
  /// use the batchStudentsProvider directly in UI components.
  Future<int> getBatchStudentCount(int batchId) async {
    try {
      final students = await _batchService.getBatchStudents(batchId);
      return students.length;
    } catch (e) {
      return 0; // Return 0 on error to not break UI
    }
  }

  /// Get upcoming batches (today after current time + future days)
  Future<List<Batch>> getUpcomingBatches() async {
    try {
      final now = DateTime.now();
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final todayDayName = dayNames[now.weekday - 1];
      
      // Get all batches
      final allBatches = await _batchService.getBatches();
      
      final upcomingBatches = <Batch>[];
      
      // First, get batches for today that haven't finished
      final todayBatches = allBatches.where((batch) {
        if (!_batchRunsOnDay(batch, todayDayName)) return false;
        return BatchTimeUtils.isBatchUpcoming(batch);
      }).toList();
      
      // Sort by timing
      todayBatches.sort((a, b) {
        final aTime = BatchTimeUtils.parseBatchEndTime(a.timing);
        final bTime = BatchTimeUtils.parseBatchEndTime(b.timing);
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });
      
      upcomingBatches.addAll(todayBatches);
      
      // Then get batches from future days (next 7 days)
      for (int i = 1; i <= 7 && upcomingBatches.length < 5; i++) {
        final checkDate = now.add(Duration(days: i));
        final checkDayName = dayNames[checkDate.weekday - 1];
        
        final futureBatches = allBatches.where((batch) {
          return _batchRunsOnDay(batch, checkDayName);
        }).toList();
        
        // Sort by timing
        futureBatches.sort((a, b) {
          final aTime = BatchTimeUtils.parseBatchEndTime(a.timing);
          final bTime = BatchTimeUtils.parseBatchEndTime(b.timing);
          if (aTime == null || bTime == null) return 0;
          return aTime.compareTo(bTime);
        });
        
        for (final batch in futureBatches) {
          if (upcomingBatches.length >= 5) break;
          // Avoid duplicates
          if (!upcomingBatches.any((b) => b.id == batch.id)) {
            upcomingBatches.add(batch);
          }
        }
      }
      
      return upcomingBatches.take(5).toList();
    } catch (e) {
      return []; // Return empty list on error
    }
  }
}
