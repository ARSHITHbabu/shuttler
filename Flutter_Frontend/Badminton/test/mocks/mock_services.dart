import 'package:badminton/core/services/api_service.dart';
import 'package:badminton/core/services/student_service.dart';
import 'package:badminton/core/services/fee_service.dart';
import 'package:badminton/core/services/performance_service.dart';
import 'package:badminton/core/services/bmi_service.dart';
import 'package:badminton/core/services/notification_service.dart';
import 'package:badminton/core/services/announcement_service.dart';
import 'package:badminton/core/services/calendar_service.dart';
import 'package:badminton/core/network/request_queue.dart';
import 'package:badminton/models/student.dart';
import 'package:badminton/models/fee.dart';
import 'package:badminton/models/performance.dart';
import 'package:badminton/models/bmi_record.dart';
import 'package:badminton/models/notification.dart';
import 'package:badminton/models/announcement.dart';
import 'package:badminton/models/calendar_event.dart';
import 'package:dio/dio.dart';

/// Mock API Service for testing
class MockApiService extends ApiService {
  final Map<String, dynamic> _mockData;
  bool _shouldThrowError = false;
  String? _errorMessage;

  MockApiService(super.storageService, this._mockData);

  void setShouldThrowError(bool shouldThrow, {String? message}) {
    _shouldThrowError = shouldThrow;
    _errorMessage = message;
  }

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    if (_shouldThrowError) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        error: _errorMessage ?? 'Mock error',
      );
    }

    final key = path.replaceAll('/api/', '').replaceAll('/', '_');
    final data = _mockData[key] ?? [];
    
    return Response(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    if (_shouldThrowError) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        error: _errorMessage ?? 'Mock error',
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'id': 1, ...?data},
      statusCode: 201,
    );
  }

  @override
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    if (_shouldThrowError) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        error: _errorMessage ?? 'Mock error',
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'id': 1, ...?data},
      statusCode: 200,
    );
  }

  @override
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    if (_shouldThrowError) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        error: _errorMessage ?? 'Mock error',
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'success': true},
      statusCode: 200,
    );
  }
}

/// Mock Student Service for testing
class MockStudentService extends StudentService {
  final List<Student> _mockStudents;
  bool _shouldThrowError = false;

  MockStudentService(super.apiService, this._mockStudents);

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  @override
  Future<List<Student>> getStudents() async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to fetch students');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockStudents;
  }

  @override
  Future<Student> getStudentById(int id) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to fetch student');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockStudents.firstWhere((s) => s.id == id);
  }

  @override
  Future<Student> createStudent(Map<String, dynamic> studentData) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to create student');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    final student = Student.fromJson({
      'id': _mockStudents.length + 1,
      ...studentData,
    });
    _mockStudents.add(student);
    return student;
  }

  @override
  Future<Student> updateStudent(int id, Map<String, dynamic> studentData) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to update student');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _mockStudents.indexWhere((s) => s.id == id);
    if (index != -1) {
      _mockStudents[index] = Student.fromJson({
        ..._mockStudents[index].toJson(),
        ...studentData,
      });
      return _mockStudents[index];
    }
    throw Exception('Student not found');
  }

  @override
  Future<void> deleteStudent(int id) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to delete student');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    _mockStudents.removeWhere((s) => s.id == id);
  }
}

/// Mock Fee Service for testing
class MockFeeService extends FeeService {
  final List<Fee> _mockFees;
  bool _shouldThrowError = false;

  MockFeeService(super.apiService, this._mockFees);

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  @override
  Future<List<Fee>> getFees({
    int? studentId,
    int? batchId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to fetch fees');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockFees.where((fee) {
      if (studentId != null && fee.studentId != studentId) return false;
      if (status != null && fee.status != status) return false;
      return true;
    }).toList();
  }
}

/// Mock Performance Service for testing
class MockPerformanceService extends PerformanceService {
  final List<Performance> _mockPerformances;
  bool _shouldThrowError = false;

  MockPerformanceService(super.apiService, this._mockPerformances);

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  Future<List<Performance>> getPerformanceByStudent(int studentId) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to fetch performance');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockPerformances.where((p) => p.studentId == studentId).toList();
  }
}

/// Mock BMI Service for testing
class MockBMIService extends BMIService {
  final List<BMIRecord> _mockBMIRecords;
  bool _shouldThrowError = false;

  MockBMIService(super.apiService, this._mockBMIRecords);

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  Future<List<BMIRecord>> getBMIRecordsByStudent(int studentId) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to fetch BMI records');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockBMIRecords.where((b) => b.studentId == studentId).toList();
  }
}

/// Mock Notification Service for testing
class MockNotificationService extends NotificationService {
  final List<Notification> _mockNotifications;
  bool _shouldThrowError = false;

  MockNotificationService(super.apiService, this._mockNotifications);

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  @override
  Future<List<Notification>> getNotifications({
    required int userId,
    required String userType,
    String? type,
    bool? isRead,
  }) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to fetch notifications');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockNotifications.where((n) {
      if (n.userId != userId || n.userType != userType) return false;
      if (type != null && n.type != type) return false;
      if (isRead != null && n.isRead != isRead) return false;
      return true;
    }).toList();
  }
}

/// Mock Announcement Service for testing
class MockAnnouncementService extends AnnouncementService {
  final List<Announcement> _mockAnnouncements;
  bool _shouldThrowError = false;

  MockAnnouncementService(super.apiService, this._mockAnnouncements);

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  @override
  Future<List<Announcement>> getAnnouncements({
    String? targetAudience,
    String? priority,
    bool? isSent,
  }) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to fetch announcements');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockAnnouncements.where((a) {
      if (targetAudience != null && a.targetAudience != targetAudience) return false;
      if (priority != null && a.priority != priority) return false;
      if (isSent != null && a.isSent != isSent) return false;
      return true;
    }).toList();
  }
}

/// Mock Calendar Service for testing
class MockCalendarService extends CalendarService {
  final List<CalendarEvent> _mockEvents;
  bool _shouldThrowError = false;

  MockCalendarService(super.apiService, this._mockEvents);

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  Future<List<CalendarEvent>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_shouldThrowError) {
      throw Exception('Mock error: Failed to fetch events');
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockEvents.where((e) {
      if (startDate != null && e.date.isBefore(startDate)) return false;
      if (endDate != null && e.date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }
}

/// Helper class to create mock data for tests
class MockDataFactory {
  static List<Student> createMockStudents(int count) {
    return List.generate(count, (index) {
      return Student(
        id: index + 1,
        name: 'Student ${index + 1}',
        email: 'student${index + 1}@example.com',
        phone: '123456789$index',
        dateOfBirth: '2000-01-01',
        address: 'Address ${index + 1}',
        status: 'active',
      );
    });
  }

  static List<Fee> createMockFees(int count) {
    return List.generate(count, (index) {
      final amount = 1000.0 + (index * 100);
      final totalPaid = index % 2 == 0 ? amount : 0.0;
      final pendingAmount = amount - totalPaid;
      return Fee(
        id: index + 1,
        studentId: index + 1,
        batchId: 1,
        amount: amount,
        totalPaid: totalPaid,
        pendingAmount: pendingAmount,
        dueDate: DateTime.now().add(Duration(days: index * 7)),
        status: index % 2 == 0 ? 'paid' : 'pending',
        createdAt: DateTime.now(),
      );
    });
  }

  static List<Performance> createMockPerformances(int count) {
    return List.generate(count, (index) {
      final baseRating = 3 + (index % 2);
      return Performance(
        id: index + 1,
        studentId: index + 1,
        date: DateTime.now().subtract(Duration(days: index * 7)),
        serve: baseRating,
        smash: baseRating,
        footwork: baseRating,
        defense: baseRating,
        stamina: baseRating,
        comments: 'Comment ${index + 1}',
      );
    });
  }

  static List<BMIRecord> createMockBMIRecords(int count) {
    return List.generate(count, (index) {
      return BMIRecord(
        id: index + 1,
        studentId: index + 1,
        date: DateTime.now().subtract(Duration(days: index * 30)),
        height: 150.0 + (index * 5),
        weight: 40.0 + (index * 2),
        bmi: 18.0 + (index * 0.5),
      );
    });
  }

  static List<Notification> createMockNotifications(int count) {
    return List.generate(count, (index) {
      return Notification(
        id: index + 1,
        userId: 1,
        userType: 'student',
        title: 'Notification ${index + 1}',
        body: 'Message ${index + 1}',
        type: index % 2 == 0 ? 'announcement' : 'fee_due',
        isRead: index % 3 == 0,
        createdAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  static List<Announcement> createMockAnnouncements(int count) {
    return List.generate(count, (index) {
      return Announcement(
        id: index + 1,
        title: 'Announcement ${index + 1}',
        message: 'Message ${index + 1}',
        priority: index % 3 == 0 ? 'urgent' : 'normal',
        targetAudience: 'all',
        createdAt: DateTime.now().subtract(Duration(days: index)),
        isSent: index % 2 == 0,
      );
    });
  }

  static List<CalendarEvent> createMockEvents(int count) {
    return List.generate(count, (index) {
      return CalendarEvent(
        id: index + 1,
        title: 'Event ${index + 1}',
        description: 'Description ${index + 1}',
        date: DateTime.now().add(Duration(days: index)),
        eventType: index % 2 == 0 ? 'holiday' : 'tournament',
        createdAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }
}
