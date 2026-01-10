/// API endpoint constants for backend integration
class ApiEndpoints {
  // Base URL - Change for production
  static const String baseUrl = 'http://localhost:8000';

  // Authentication
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';

  // Coaches
  static const String coaches = '/api/coaches/';
  static String coachById(int id) => '/api/coaches/$id';

  // Students
  static const String students = '/api/students/';
  static String studentById(int id) => '/api/students/$id';
  static String studentAttendance(int id) => '/api/students/$id/attendance';
  static String studentPerformance(int id) => '/api/students/$id/performance';

  // Batches
  static const String batches = '/api/batches/';
  static String batchById(int id) => '/api/batches/$id';
  static String batchStudentsList(int id) => '/api/batches/$id/students';

  // Batch Students (enrollment)
  static const String batchStudents = '/api/batch-students/';
  static String batchStudentById(int id) => '/api/batch-students/$id';

  // Attendance
  static const String attendance = '/api/attendance/';
  static String attendanceById(int id) => '/api/attendance/$id';

  // Coach Attendance
  static const String coachAttendance = '/api/coach-attendance/';
  static String coachAttendanceById(int id) => '/api/coach-attendance/$id';

  // Fees
  static const String fees = '/api/fees/';
  static String feeById(int id) => '/api/fees/$id';

  // Performance
  static const String performance = '/api/performance/';
  static String performanceById(int id) => '/api/performance/$id';

  // BMI Records
  static const String bmiRecords = '/api/bmi-records/';
  static String bmiRecordById(int id) => '/api/bmi-records/$id';

  // Schedules (Sessions)
  static const String schedules = '/api/schedules/';
  static String scheduleById(int id) => '/api/schedules/$id';

  // Tournaments
  static const String tournaments = '/api/tournaments/';
  static String tournamentById(int id) => '/api/tournaments/$id';

  // Enquiries
  static const String enquiries = '/api/enquiries/';
  static String enquiryById(int id) => '/api/enquiries/$id';

  // Video Resources
  static const String videoResources = '/api/video-resources/';
  static String videoResourceById(int id) => '/api/video-resources/$id';

  // Invitations
  static const String invitations = '/api/invitations/';
  static String invitationById(int id) => '/api/invitations/$id';

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
