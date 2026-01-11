/// API endpoint constants for backend integration
class ApiEndpoints {
  // Base URL - Change for production
  static const String baseUrl = 'http://127.0.0.1:8000';

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
  static const String announcements = '/announcements/';
  static String announcementById(int id) => '/announcements/$id';

  // Notifications (NEW)
  static const String notifications = '/notifications/';
  static String notificationById(int id) => '/notifications/$id';
  static String userNotifications(int userId, String userType) =>
      '/notifications/$userId?user_type=$userType';
  static String markNotificationRead(int id) => '/notifications/$id/read';

  // Calendar Events (NEW)
  static const String calendarEvents = '/calendar-events/';
  static String calendarEventById(int id) => '/calendar-events/$id';

  // Image Upload (NEW)
  static const String uploadImage = '/upload/image';
  static String imageUrl(String filename) => '/uploads/$filename';
}
