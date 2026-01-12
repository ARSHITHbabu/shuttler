import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/batch_service.dart';
import '../core/services/attendance_service.dart';
import '../core/services/fee_service.dart';
import '../core/services/dashboard_service.dart';
import '../core/services/student_service.dart';
import '../core/services/coach_service.dart';
import '../core/services/performance_service.dart';
import '../core/services/bmi_service.dart';
import '../core/services/schedule_service.dart';
import '../core/services/announcement_service.dart';
import '../core/services/calendar_service.dart';

part 'service_providers.g.dart';

/// Provider for StorageService singleton
@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService();
}

/// Provider for ApiService singleton
@riverpod
ApiService apiService(ApiServiceRef ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService);
}

/// Provider for AuthService singleton
@riverpod
AuthService authService(AuthServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(apiService, storageService);
}

/// Provider for BatchService singleton
@riverpod
BatchService batchService(BatchServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BatchService(apiService);
}

/// Provider for AttendanceService singleton
@riverpod
AttendanceService attendanceService(AttendanceServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AttendanceService(apiService);
}

/// Provider for FeeService singleton
@riverpod
FeeService feeService(FeeServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FeeService(apiService);
}

/// Provider for DashboardService singleton
@riverpod
DashboardService dashboardService(DashboardServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  final batchService = ref.watch(batchServiceProvider);
  final attendanceService = ref.watch(attendanceServiceProvider);
  final feeService = ref.watch(feeServiceProvider);
  return DashboardService(apiService, batchService, attendanceService, feeService);
}

/// Provider for StudentService singleton
@riverpod
StudentService studentService(StudentServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return StudentService(apiService);
}

/// Provider for CoachService singleton
@riverpod
CoachService coachService(CoachServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CoachService(apiService);
}

/// Provider for PerformanceService singleton
@riverpod
PerformanceService performanceService(PerformanceServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PerformanceService(apiService);
}

/// Provider for BMIService singleton
@riverpod
BMIService bmiService(BmiServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BMIService(apiService);
}

/// Provider for ScheduleService singleton
@riverpod
ScheduleService scheduleService(ScheduleServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ScheduleService(apiService);
}

/// Provider for AnnouncementService singleton
@riverpod
AnnouncementService announcementService(AnnouncementServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AnnouncementService(apiService);
}

/// Provider for CalendarService singleton
@riverpod
CalendarService calendarService(CalendarServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CalendarService(apiService);
}
