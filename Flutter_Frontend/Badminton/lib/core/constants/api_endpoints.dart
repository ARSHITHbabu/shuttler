import 'package:flutter/foundation.dart' show kIsWeb;

/// API endpoint constants for backend integration
class ApiEndpoints {
  // Base URL - Use localhost for web, computer's local IP for mobile/desktop
  // IMPORTANT: Change this IP to your computer's local IP address (run ipconfig on Windows)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    // Use your computer's local network IP address
    // Your computer IP: 192.168.1.7 (as of Jan 12, 2026)
    return 'http://192.168.1.7:8000';
  }

  // Authentication
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';

  // Coaches
  static const String coaches = '/coaches/';
  static String coachById(int id) => '/coaches/$id';

  // Students
  static const String students = '/students/';
  static String studentById(int id) => '/students/$id';
  static String studentAttendance(int id) => '/students/$id/attendance';
  static String studentPerformance(int id) => '/students/$id/performance';

  // Batches
  static const String batches = '/batches/';
  static String batchById(int id) => '/batches/$id';
  static String batchStudentsList(int id) => '/batches/$id/students';

  // Batch Students (enrollment)
  static const String batchStudents = '/batch-students/';
  static String batchStudentById(int id) => '/batch-students/$id';

  // Attendance
  static const String attendance = '/attendance/';
  static String attendanceById(int id) => '/attendance/$id';

  // Coach Attendance
  static const String coachAttendance = '/coach-attendance/';
  static String coachAttendanceById(int id) => '/coach-attendance/$id';

  // Fees
  static const String fees = '/fees/';
  static String feeById(int id) => '/fees/$id';

  // Performance
  static const String performance = '/performance/';
  static String performanceById(int id) => '/performance/$id';

  // BMI Records
  static const String bmiRecords = '/bmi-records/';
  static String bmiRecordById(int id) => '/bmi-records/$id';

  // Schedules (Sessions)
  static const String schedules = '/schedules/';
  static String scheduleById(int id) => '/schedules/$id';

  // Tournaments
  static const String tournaments = '/tournaments/';
  static String tournamentById(int id) => '/tournaments/$id';

  // Enquiries
  static const String enquiries = '/enquiries/';
  static String enquiryById(int id) => '/enquiries/$id';

  // Video Resources
  static const String videoResources = '/video-resources/';
  static String videoResourceById(int id) => '/video-resources/$id';

  // Invitations
  static const String invitations = '/invitations/';
  static String invitationById(int id) => '/invitations/$id';

  // Announcements (NEW)
  static const String announcements = '/api/announcements/';
  static String announcementById(int id) => '/api/announcements/$id';

  // Notifications (NEW)
  static const String notifications = '/api/notifications/';
  static String notificationById(int id) => '/api/notifications/$id';
  static String userNotifications(int userId, String userType) =>
      '/api/notifications/$userId?user_type=$userType';
  static String markNotificationRead(int id) => '/api/notifications/$id/read';

  // Calendar Events (NEW)
  static const String calendarEvents = '/api/calendar-events/';
  static String calendarEventById(int id) => '/api/calendar-events/$id';

  // Image Upload (NEW)
  static const String uploadImage = '/api/upload/image';
  static String imageUrl(String filename) => '/uploads/$filename';
}
