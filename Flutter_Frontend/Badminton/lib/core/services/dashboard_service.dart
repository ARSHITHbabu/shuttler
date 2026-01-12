import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'batch_service.dart';
import 'attendance_service.dart';
import 'fee_service.dart';

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
      // Backend doesn't have status field, so return all batches
      final batches = await _batchService.getBatches();
      return batches.length;
    } catch (e) {
      return 0; // Return 0 on error to not break dashboard
    }
  }
}
