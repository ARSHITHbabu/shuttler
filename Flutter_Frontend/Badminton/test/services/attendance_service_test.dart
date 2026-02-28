import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:badminton/core/services/attendance_service.dart';
import 'package:badminton/core/services/api_service.dart';
import 'package:badminton/models/attendance.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late AttendanceService attendanceService;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    attendanceService = AttendanceService(mockApiService);
  });

  group('AttendanceService Tests', () {
    final testDate = DateTime(2024, 1, 1);
    final attendanceData = {
      'id': 1,
      'student_id': 101,
      'batch_id': 1,
      'date': '2024-01-01',
      'status': 'present',
      'marked_by': 'Owner',
    };

    test('getAttendance by batch and date should return list', () async {
      // Setup
      when(() => mockApiService.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [attendanceData],
            statusCode: 200,
          ));

      // Execute
      final result = await attendanceService.getAttendance(batchId: 1, date: testDate);

      // Verify
      expect(result.length, 1);
      expect(result[0].status, 'present');
      verify(() => mockApiService.get('/attendance/batch/1/date/2024-01-01')).called(1);
    });

    test('markStudentAttendance should post data correctly', () async {
      // Setup
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: attendanceData,
                statusCode: 201,
              ));

      // Execute
      final result = await attendanceService.markStudentAttendance(
        studentId: 101,
        batchId: 1,
        date: testDate,
        status: 'present',
      );

      // Verify
      expect(result.studentId, 101);
      final captured = verify(() => mockApiService.post(any(), data: captureAny(named: 'data'))).captured.last;
      expect(captured['status'], 'present');
      expect(captured['date'], '2024-01-01');
    });

    test('getTodayAttendanceRate should calculate percentage', () async {
      // Setup
      when(() => mockApiService.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: [
                  {'status': 'present'},
                  {'status': 'absent'},
                ],
                statusCode: 200,
              ));

      // Execute
      final result = await attendanceService.getTodayAttendanceRate();

      // Verify
      expect(result, 50.0);
    });
  });
}
