import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/batch.dart';
import '../models/schedule.dart';
import '../models/announcement.dart';
import '../models/coach.dart';
import '../models/student.dart';
import '../utils/batch_time_utils.dart';
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
  final batches = await batchService.getBatchesByCoachId(coachId);
  // Sort by ID descending (latest first)
  return batches..sort((a, b) => b.id.compareTo(a.id));
}

/// Provider for coach statistics
@riverpod
Future<CoachStats> coachStats(CoachStatsRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  final attendanceService = ref.watch(attendanceServiceProvider);
  
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
  // Count batches that run today and are upcoming (like owner dashboard)
  final today = DateTime.now();
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final todayDayName = dayNames[today.weekday - 1];
  
  int sessionsToday = 0;
  for (var batch in assignedBatches) {
    // Check if batch runs today
    final runsToday = batch.period.toLowerCase() == 'daily' || 
                      batch.days.contains(todayDayName);
    if (!runsToday) continue;
    
    // Check if batch is upcoming (hasn't finished yet)
    if (BatchTimeUtils.isBatchUpcoming(batch)) {
      sessionsToday++;
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
/// Works directly with batches (like owner dashboard) instead of requiring Schedule records
/// Converts batches to Schedule objects for display compatibility
@riverpod
Future<List<Schedule>> coachTodaySessions(CoachTodaySessionsRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  final today = DateTime.now();
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final todayDayName = dayNames[today.weekday - 1];
  
  // Get coach's assigned batches
  final coachBatches = await batchService.getBatchesByCoachId(coachId);
  
  // Filter batches that run today and are upcoming (haven't finished)
  final todayBatches = coachBatches.where((batch) {
    // Check if batch runs today
    final runsToday = batch.period.toLowerCase() == 'daily' || 
                      batch.days.contains(todayDayName);
    if (!runsToday) return false;
    
    // Check if batch is upcoming (hasn't finished yet)
    return BatchTimeUtils.isBatchUpcoming(batch);
  }).toList();
  
  // Convert batches to Schedule objects for display compatibility
  List<Schedule> todaySessions = [];
  for (var batch in todayBatches) {
    try {
      // Parse timing to extract start and end times
      final startTimeStr = BatchTimeUtils.parseBatchStartTimeString(batch.timing);
      final endTimeStr = BatchTimeUtils.parseBatchEndTimeString(batch.timing);
      
      // Calculate duration in minutes if we have both times
      int? duration;
      if (startTimeStr != null && endTimeStr != null) {
        final startTime = BatchTimeUtils.parseTimeString(startTimeStr);
        final endTime = BatchTimeUtils.parseTimeString(endTimeStr);
        if (startTime != null && endTime != null) {
          duration = endTime.difference(startTime).inMinutes;
        }
      }
      
      // Create Schedule object from batch
      final schedule = Schedule(
        id: batch.id, // Use batch ID as schedule ID for uniqueness
        sessionType: 'practice', // Default to practice
        title: batch.batchName,
        date: DateTime(today.year, today.month, today.day),
        startTime: startTimeStr,
        endTime: endTimeStr,
        duration: duration,
        batchId: batch.id,
        batchName: batch.batchName,
        location: batch.location,
        coachId: coachId,
        coachName: batch.coachNamesString.isNotEmpty 
            ? batch.coachNamesString 
            : batch.coachName,
        capacity: batch.capacity,
      );
      
      todaySessions.add(schedule);
    } catch (e) {
      // Skip if error converting batch to schedule
      continue;
    }
  }
  
  // Sort by start time
  todaySessions.sort((a, b) {
    if (a.startTime == null || b.startTime == null) return 0;
    final aTime = BatchTimeUtils.parseTimeString(a.startTime!);
    final bTime = BatchTimeUtils.parseTimeString(b.startTime!);
    if (aTime == null || bTime == null) return 0;
    return aTime.compareTo(bTime);
  });
  
  return todaySessions;
}

/// Provider for coach's upcoming sessions (next 7 days)
/// Similar logic to student dashboard but for all batches assigned to the coach
@riverpod
Future<List<Map<String, dynamic>>> coachUpcomingSessions(CoachUpcomingSessionsRef ref, int coachId) async {
  final batchService = ref.watch(batchServiceProvider);
  final now = DateTime.now();
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final todayDayName = dayNames[now.weekday - 1];
  
  // Get coach's assigned batches
  final coachBatches = await batchService.getBatchesByCoachId(coachId);
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
  for (var batch in coachBatches) {
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
        'batch_id': batch.id,
        'batch_name': batch.batchName,
        'time': timeStr,
        'location': batch.location ?? '',
        'date': DateTime(now.year, now.month, now.day).toIso8601String(),
      });
      batchAdded = true;
    }

    // Only check future days if batch wasn't added for today
    if (!batchAdded) {
      for (int i = 1; i <= 7 && upcomingSessions.length < 10; i++) {
        final checkDate = now.add(Duration(days: i));
        final checkDayName = dayNames[checkDate.weekday - 1];

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
            'batch_id': batch.id,
            'batch_name': batch.batchName,
            'time': timeStr,
            'location': batch.location ?? '',
            'date': dateStr,
          });
          break;
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

  return upcomingSessions.take(5).toList();
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
