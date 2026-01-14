import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/batch.dart';
import '../models/schedule.dart';
import '../models/announcement.dart';
import 'service_providers.dart';

part 'coach_provider.g.dart';

/// Provider for coach's assigned batches
@riverpod
Future<List<Batch>> coachBatches(CoachBatchesRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  final allBatches = await batchService.getBatches();
  // Filter batches assigned to this coach
  return allBatches.where((batch) => batch.assignedCoachId == coachId).toList();
}

/// Provider for coach statistics
@riverpod
Future<CoachStats> coachStats(CoachStatsRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  final attendanceService = ref.watch(attendanceServiceProvider);
  
  // Get assigned batches
  final allBatches = await batchService.getBatches();
  final assignedBatches = allBatches.where((batch) => batch.assignedCoachId == coachId).toList();
  
  // Calculate total students across all batches
  int totalStudents = 0;
  for (var batch in assignedBatches) {
    try {
      final students = await batchService.getBatchStudents(batch.id);
      totalStudents += students.length;
    } catch (e) {
      // Skip if error fetching students for this batch
    }
  }
  
  // Get today's sessions count
  final scheduleService = ref.watch(scheduleServiceProvider);
  final today = DateTime.now();
  final allTodaySessions = await scheduleService.getSchedules(
    startDate: today,
    endDate: today,
  );
  // Filter schedules assigned to this coach
  final todaySessions = allTodaySessions.where((schedule) => schedule.coachId == coachId).toList();
  
  // Calculate attendance rate (last 30 days)
  final thirtyDaysAgo = today.subtract(const Duration(days: 30));
  int totalAttendanceRecords = 0;
  int presentRecords = 0;
  
  for (var batch in assignedBatches) {
    try {
      final attendance = await attendanceService.getAttendance(
        batchId: batch.id,
        startDate: thirtyDaysAgo,
        endDate: today,
      );
      totalAttendanceRecords += attendance.length;
      presentRecords += attendance.where((a) => a.status == 'present').length;
    } catch (e) {
      // Skip if error
    }
  }
  
  final attendanceRate = totalAttendanceRecords > 0
      ? (presentRecords / totalAttendanceRecords) * 100
      : 0.0;
  
  return CoachStats(
    assignedBatches: assignedBatches.length,
    totalStudents: totalStudents,
    sessionsToday: todaySessions.length,
    attendanceRate: attendanceRate,
  );
}

/// Provider for coach's today sessions
@riverpod
Future<List<Schedule>> coachTodaySessions(CoachTodaySessionsRef ref, int coachId) async {
  final scheduleService = ref.watch(scheduleServiceProvider);
  final today = DateTime.now();
  // Get all schedules for today, then filter by coachId
  final allSchedules = await scheduleService.getSchedules(
    startDate: today,
    endDate: today,
  );
  // Filter schedules assigned to this coach
  return allSchedules.where((schedule) => schedule.coachId == coachId).toList();
}

/// Provider for coach announcements (filtered for coaches)
@riverpod
Future<List<Announcement>> coachAnnouncements(CoachAnnouncementsRef ref) async {
  final announcementService = ref.watch(announcementServiceProvider);
  final allAnnouncements = await announcementService.getAnnouncements();
  // Filter announcements for coaches
  return allAnnouncements.where((announcement) {
    return announcement.targetAudience == 'all' || 
           announcement.targetAudience == 'coaches';
  }).toList();
}

/// Coach statistics model
class CoachStats {
  final int assignedBatches;
  final int totalStudents;
  final int sessionsToday;
  final double attendanceRate;

  CoachStats({
    required this.assignedBatches,
    required this.totalStudents,
    required this.sessionsToday,
    required this.attendanceRate,
  });
}
