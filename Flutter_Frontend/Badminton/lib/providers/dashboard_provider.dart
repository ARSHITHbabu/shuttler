import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/batch.dart';
import '../models/batch_attendance.dart';
import 'service_providers.dart';

part 'dashboard_provider.g.dart';

/// Provider for dashboard statistics
@riverpod
class DashboardStats extends _$DashboardStats {
  @override
  Future<DashboardStatsData> build() async {
    final dashboardService = ref.watch(dashboardServiceProvider);
    final stats = await dashboardService.getDashboardStats();
    
    // Calculate attendance rate from finished batches
    final finishedBatches = await dashboardService.getFinishedBatchesWithAttendance();
    double attendanceRate = 0.0;
    if (finishedBatches.isNotEmpty) {
      final totalRate = finishedBatches.fold<double>(
        0.0,
        (sum, batch) => sum + batch.attendanceRate,
      );
      attendanceRate = totalRate / finishedBatches.length;
    }
    
    return DashboardStatsData(
      totalStudents: stats.totalStudents,
      totalCoaches: stats.totalCoaches,
      activeBatches: stats.activeBatches,
      pendingFees: stats.pendingFees,
      todayAttendanceRate: attendanceRate,
    );
  }

  /// Refresh dashboard statistics
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dashboardService = ref.read(dashboardServiceProvider);
      final stats = await dashboardService.getDashboardStats();
      
      // Calculate attendance rate from finished batches
      final finishedBatches = await dashboardService.getFinishedBatchesWithAttendance();
      double attendanceRate = 0.0;
      if (finishedBatches.isNotEmpty) {
        final totalRate = finishedBatches.fold<double>(
          0.0,
          (sum, batch) => sum + batch.attendanceRate,
        );
        attendanceRate = totalRate / finishedBatches.length;
      }
      
      return DashboardStatsData(
        totalStudents: stats.totalStudents,
        totalCoaches: stats.totalCoaches,
        activeBatches: stats.activeBatches,
        pendingFees: stats.pendingFees,
        todayAttendanceRate: attendanceRate,
      );
    });
  }
}

/// Dashboard statistics data class
class DashboardStatsData {
  final int totalStudents;
  final int totalCoaches;
  final int activeBatches;
  final double pendingFees;
  final double todayAttendanceRate;

  DashboardStatsData({
    required this.totalStudents,
    required this.totalCoaches,
    required this.activeBatches,
    required this.pendingFees,
    required this.todayAttendanceRate,
  });
}

/// Provider for finished batches with attendance rates
@riverpod
Future<List<BatchAttendance>> finishedBatchesWithAttendance(FinishedBatchesWithAttendanceRef ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return await dashboardService.getFinishedBatchesWithAttendance();
}

/// Provider for upcoming batches
@riverpod
Future<List<Batch>> upcomingBatches(UpcomingBatchesRef ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return await dashboardService.getUpcomingBatches();
}
