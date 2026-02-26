import 'package:flutter/foundation.dart' show kIsWeb;

/// API endpoint constants for backend integration
class ApiEndpoints {
  // Base URL - Use localhost for web, computer's local IP for mobile/desktop
  // IMPORTANT: Change this IP to your computer's local IP address (run ipconfig on Windows)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8001';
    }
    // Use your computer's local network IP address
    // Run get_local_ip.ps1 to find your current IP address
    // Current IP: 192.168.1.11 (updated automatically)
    return 'http://192.168.1.11:8001';
    // Current IP: 192.168.1.7 (updated automatically)
    return 'http://192.168.1.7:8001';
  }

  // Authentication
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Owners
  static const String owners = '/owners/';
  static String ownerById(int id) => '/owners/$id';
  static const String ownerLogin = '/owners/login';

  // Coaches
  static const String coaches = '/coaches/';
  static String coachById(int id) => '/coaches/$id';

  // Students
  static const String students = '/students/';
  static String studentById(int id) => '/students/$id';
  static String studentPerformance(int id) => '/students/$id/performance';
  static String deactivateStudent(int id) => '/students/$id/deactivate';
  static String removeStudent(int id) => '/students/$id/remove';
  static String requestRejoin(int id) => '/students/$id/request-rejoin';
  static String approveRejoin(int id) => '/students/$id/approve-rejoin';

  // Sessions (Seasons)
  static const String sessions = '/sessions/';
  static String sessionById(int id) => '/sessions/$id';
  static String sessionBatches(int id) => '/sessions/$id/batches';

  // Batches
  static const String batches = '/batches/';
  static String batchById(int id) => '/batches/$id';
  static String batchStudentsList(int id) => '/batches/$id/students';
  static String deactivateBatch(int id) => '/batches/$id/deactivate';
  static String removeBatch(int id) => '/batches/$id/remove';

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

  // Video streaming and handling (Modified to support Range requests)
  static String videoStreamUrl(String videoPath) {
    if (videoPath.startsWith('/uploads/')) {
      final filename = videoPath.replaceFirst('/uploads/', '');
      return '/video-stream/$filename';
    }
    return videoPath;
  }

  // Image Upload (NEW)
  static const String uploadImage = '/api/upload/image';
  static String imageUrl(String filename) => '/uploads/$filename';

  // Leave Requests
  static const String leaveRequests = '/leave-requests/';
  static String leaveRequestById(int id) => '/leave-requests/$id';
}
