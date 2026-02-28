import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:badminton/core/services/student_service.dart';
import 'package:badminton/core/services/api_service.dart';
import 'package:badminton/models/student.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late StudentService studentService;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    studentService = StudentService(mockApiService);
  });

  group('StudentService Tests', () {
    const student1 = {
      'id': 1,
      'name': 'Student One',
      'email': 'student1@test.com',
      'phone': '1234567890',
      'guardian_name': 'Guardian One',
      'status': 'active',
    };

    const student2 = {
      'id': 2,
      'name': 'Student Two',
      'email': 'student2@test.com',
      'phone': '0987654321',
      'guardian_name': 'Guardian Two',
      'status': 'active',
    };

    test('getStudents should return list of students', () async {
      // Setup
      when(() => mockApiService.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [student1, student2],
            statusCode: 200,
          ));

      // Execute
      final result = await studentService.getStudents();

      // Verify
      expect(result.length, 2);
      expect(result[0].name, 'Student One');
      expect(result[1].name, 'Student Two');
    });

    test('getStudentById should return a student', () async {
      // Setup
      when(() => mockApiService.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: student1,
            statusCode: 200,
          ));

      // Execute
      final result = await studentService.getStudentById(1);

      // Verify
      expect(result.id, 1);
      expect(result.name, 'Student One');
    });

    test('updateStudent should return updated student', () async {
      // Setup
      final updatedData = {'name': 'Updated Name'};
      when(() => mockApiService.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {...student1, ...updatedData},
                statusCode: 200,
              ));

      // Execute
      final result = await studentService.updateStudent(1, updatedData);

      // Verify
      expect(result.name, 'Updated Name');
    });
  });
}
