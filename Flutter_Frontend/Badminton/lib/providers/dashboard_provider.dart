import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/batch.dart';
import '../models/batch_attendance.dart';
import '../utils/batch_time_utils.dart';
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

/// Provider for upcoming sessions for all active batches (Owner view)
/// Shows next occurrence for each active batch
@riverpod
Future<List<Map<String, dynamic>>> ownerUpcomingSessions(OwnerUpcomingSessionsRef ref) async {
  final batchService = ref.watch(batchServiceProvider);
  final now = DateTime.now();
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final todayDayName = dayNames[now.weekday - 1];
  
  // Get all active batches
  final allBatches = await batchService.getBatches();
  final activeBatches = allBatches.where((b) => b.status == 'active').toList();
  final upcomingSessions = <Map<String, dynamic>>[];

  for (var batch in activeBatches) {
    bool batchAdded = false;

    // Check if batch runs today
    final runsToday =
        batch.period.toLowerCase() == 'daily' ||
        batch.days.contains(todayDayName);

    if (runsToday && BatchTimeUtils.isBatchUpcoming(batch)) {
      upcomingSessions.add({
        'batch_id': batch.id,
        'batch_name': batch.name,
        'time': batch.timing,
        'location': batch.location ?? '',
        'date': DateTime(now.year, now.month, now.day).toIso8601String(),
      });
      batchAdded = true;
    }

    if (!batchAdded) {
      for (int i = 1; i <= 7 && upcomingSessions.length < 20; i++) {
        final checkDate = now.add(Duration(days: i));
        final checkDayName = dayNames[checkDate.weekday - 1];

        if (batch.period.toLowerCase() == 'daily' || batch.days.contains(checkDayName)) {
          upcomingSessions.add({
            'batch_id': batch.id,
            'batch_name': batch.name,
            'time': batch.timing,
            'location': batch.location ?? '',
            'date': DateTime(checkDate.year, checkDate.month, checkDate.day).toIso8601String(),
          });
          break;
        }
      }
    }
  }

  upcomingSessions.sort((a, b) {
    try {
      final dateA = DateTime.parse(a['date'] as String);
      final dateB = DateTime.parse(b['date'] as String);
      return dateA.compareTo(dateB);
    } catch (_) {
      return 0;
    }
  });

  return upcomingSessions.take(5).toList();
}
