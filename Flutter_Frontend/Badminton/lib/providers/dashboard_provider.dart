import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/batch.dart';
import 'service_providers.dart';

part 'dashboard_provider.g.dart';

/// Provider for dashboard statistics
@riverpod
class DashboardStats extends _$DashboardStats {
  @override
  Future<DashboardStatsData> build() async {
    final dashboardService = ref.watch(dashboardServiceProvider);
    final stats = await dashboardService.getDashboardStats();
    return DashboardStatsData(
      totalStudents: stats.totalStudents,
      totalCoaches: stats.totalCoaches,
      activeBatches: stats.activeBatches,
      pendingFees: stats.pendingFees,
      todayAttendanceRate: stats.todayAttendanceRate,
    );
  }

  /// Refresh dashboard statistics
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dashboardService = ref.read(dashboardServiceProvider);
      final stats = await dashboardService.getDashboardStats();
      return DashboardStatsData(
        totalStudents: stats.totalStudents,
        totalCoaches: stats.totalCoaches,
        activeBatches: stats.activeBatches,
        pendingFees: stats.pendingFees,
        todayAttendanceRate: stats.todayAttendanceRate,
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

/// Provider for upcoming batches
@riverpod
Future<List<Batch>> upcomingBatches(UpcomingBatchesRef ref) async {
  final batchService = ref.watch(batchServiceProvider);
  final batches = await batchService.getBatches();
  
  // Sort by timing and return first 2-3 upcoming batches
  final now = DateTime.now();
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final todayDayName = dayNames[now.weekday - 1];
  
  // Filter batches that have today in their days list
  final todayBatches = batches.where((batch) {
    return batch.days.contains(todayDayName);
  }).toList();
  
  // Sort by timing (extract time from timing string)
  todayBatches.sort((a, b) {
    // Simple string comparison of timing
    return a.timing.compareTo(b.timing);
  });
  
  return todayBatches.take(3).toList();
}
