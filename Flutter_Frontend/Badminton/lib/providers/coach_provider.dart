import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/batch.dart';
import '../models/schedule.dart';
import '../models/announcement.dart';
import '../models/coach.dart';
import '../models/student.dart';
import 'service_providers.dart';

part 'coach_provider.g.dart';

/// Provider for coach by ID
@riverpod
Future<Coach> coachById(CoachByIdRef ref, int id) async {
  final coachService = ref.watch(coachServiceProvider);
  return coachService.getCoachById(id);
}

/// Provider for coach's assigned batches
@riverpod
Future<List<Batch>> coachBatches(CoachBatchesRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  // Use optimized endpoint to get batches directly for this coach
  return batchService.getBatchesByCoachId(coachId);
}

/// Provider for coach statistics
@riverpod
Future<CoachStats> coachStats(CoachStatsRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  final attendanceService = ref.watch(attendanceServiceProvider);
  final scheduleService = ref.watch(scheduleServiceProvider);
  
  // Get assigned batches using optimized endpoint
  final assignedBatches = await batchService.getBatchesByCoachId(coachId);
  
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
  // Since schedules don't have coach_id, get through batches
  final today = DateTime.now();
  int sessionsToday = 0;
  for (var batch in assignedBatches) {
    try {
      final batchSchedules = await scheduleService.getSchedules(batchId: batch.id);
      final todayBatchSessions = batchSchedules.where((schedule) {
        final scheduleDate = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
        final todayDate = DateTime(today.year, today.month, today.day);
        return scheduleDate.isAtSameMomentAs(todayDate);
      }).toList();
      sessionsToday += todayBatchSessions.length;
    } catch (e) {
      // Skip if error
    }
  }
  
  // Calculate coach's own attendance rate using coach attendance records
  double attendanceRate = 0.0;
  try {
    final coachAttendance = await attendanceService.getCoachAttendanceByCoachId(coachId);
    if (coachAttendance.isNotEmpty) {
      final presentRecords = coachAttendance.where((a) =>
        a.status.toLowerCase() == 'present'
      ).length;
      attendanceRate = (presentRecords / coachAttendance.length) * 100;
    }
  } catch (e) {
    // If error fetching coach attendance, return 0.0
    attendanceRate = 0.0;
  }
  
  return CoachStats(
    assignedBatches: assignedBatches.length,
    totalStudents: totalStudents,
    sessionsToday: sessionsToday,
    attendanceRate: attendanceRate,
  );
}

/// Provider for coach's today sessions
/// Since schedules don't have coach_id directly, we get schedules through batches
@riverpod
Future<List<Schedule>> coachTodaySessions(CoachTodaySessionsRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  final scheduleService = ref.watch(scheduleServiceProvider);
  final today = DateTime.now();
  
  // Get coach's assigned batches first
  final coachBatches = await batchService.getBatchesByCoachId(coachId);
  
  // Get schedules for each batch and filter by today's date
  List<Schedule> todaySessions = [];
  for (var batch in coachBatches) {
    try {
      // Get schedules for this batch
      final batchSchedules = await scheduleService.getSchedules(batchId: batch.id);
      // Filter by today's date
      final todayBatchSessions = batchSchedules.where((schedule) {
        final scheduleDate = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
        final todayDate = DateTime(today.year, today.month, today.day);
        return scheduleDate.isAtSameMomentAs(todayDate);
      }).toList();
      
      // Add batch name to schedules for display
      final sessionsWithBatchName = todayBatchSessions.map((schedule) {
        return schedule.copyWith(
          batchName: batch.batchName,
          coachId: coachId,
          coachName: batch.assignedCoachName,
        );
      }).toList();
      
      todaySessions.addAll(sessionsWithBatchName);
    } catch (e) {
      // Skip if error fetching schedules for this batch
      continue;
    }
  }
  
  return todaySessions;
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

/// Provider for coach's all sessions (upcoming and past)
/// Gets schedules through coach's batches
@riverpod
Future<List<Schedule>> coachSchedule(CoachScheduleRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  final scheduleService = ref.watch(scheduleServiceProvider);
  
  // Get coach's assigned batches
  final coachBatches = await batchService.getBatchesByCoachId(coachId);
  
  // Get schedules for each batch
  List<Schedule> allSessions = [];
  for (var batch in coachBatches) {
    try {
      final batchSchedules = await scheduleService.getSchedules(batchId: batch.id);
      // Add batch name and coach info to schedules
      final sessionsWithInfo = batchSchedules.map((schedule) {
        return schedule.copyWith(
          batchName: batch.batchName,
          coachId: coachId,
          coachName: batch.assignedCoachName,
        );
      }).toList();
      allSessions.addAll(sessionsWithInfo);
    } catch (e) {
      // Skip if error fetching schedules for this batch
      continue;
    }
  }
  
  // Sort by date (newest first)
  allSessions.sort((a, b) => b.date.compareTo(a.date));
  
  return allSessions;
}

/// Provider for coach list state
@riverpod
class CoachList extends _$CoachList {
  @override
  Future<List<Coach>> build() async {
    final coachService = ref.watch(coachServiceProvider);
    return coachService.getCoaches();
  }

  /// Refresh coach list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final coachService = ref.read(coachServiceProvider);
      return coachService.getCoaches();
    });
  }

  /// Update a coach
  Future<void> updateCoach(int id, Map<String, dynamic> coachData) async {
    try {
      final coachService = ref.read(coachServiceProvider);
      await coachService.updateCoach(id, coachData);
      await refresh();
    } catch (e) {
      throw Exception('Failed to update coach: $e');
    }
  }

  /// Delete a coach
  Future<void> deleteCoach(int id) async {
    try {
      final coachService = ref.read(coachServiceProvider);
      await coachService.deleteCoach(id);
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete coach: $e');
    }
  }
}

/// Provider for coach's students (students in all batches assigned to coach)
@riverpod
Future<List<Student>> coachStudents(CoachStudentsRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  
  // Get coach's assigned batches
  final batches = await batchService.getBatchesByCoachId(coachId);
  
  // Get all students from all batches
  Set<Student> uniqueStudents = {};
  for (var batch in batches) {
    try {
      final students = await batchService.getBatchStudents(batch.id);
      uniqueStudents.addAll(students);
    } catch (e) {
      // Skip if error fetching students for this batch
    }
  }
  
  // Convert to list and sort by name
  final studentsList = uniqueStudents.toList();
  studentsList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  
  return studentsList;
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
