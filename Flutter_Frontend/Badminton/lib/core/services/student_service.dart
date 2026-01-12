import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/student.dart';

/// Service for student-related API operations
class StudentService {
  final ApiService _apiService;

  StudentService(this._apiService);

  /// Get all students
  Future<List<Student>> getStudents() async {
    try {
      final response = await _apiService.get(ApiEndpoints.students);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Student.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch students: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get student by ID
  Future<Student> getStudentById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.studentById(id));
      return Student.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch student: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new student
  Future<Student> createStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.students,
        data: studentData,
      );
      return Student.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create student: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a student
  Future<Student> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.studentById(id),
        data: studentData,
      );
      return Student.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update student: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a student
  Future<void> deleteStudent(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.studentById(id));
    } catch (e) {
      throw Exception('Failed to delete student: ${_apiService.getErrorMessage(e)}');
    }
  }
}
