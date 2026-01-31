import 'api_service.dart';
import '../../models/student_registration_request.dart';

/// Service for student registration request-related API operations
class StudentRegistrationRequestService {
  final ApiService _apiService;

  StudentRegistrationRequestService(this._apiService);

  /// Create a student registration request
  Future<StudentRegistrationRequest> createRequest({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? guardianName,
    String? guardianPhone,
    String? dateOfBirth,
    String? address,
    String? tShirtSize,
  }) async {
    final response = await _apiService.post(
      '/students/registration-request',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'guardian_name': guardianName,
        'guardian_phone': guardianPhone,
        'date_of_birth': dateOfBirth,
        'address': address,
        't_shirt_size': tShirtSize,
      },
    );

    return StudentRegistrationRequest.fromJson(response.data);
  }

  /// Get all registration requests (owner only)
  Future<List<StudentRegistrationRequest>> getRequests({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) {
      queryParams['status'] = status;
    }
    final response = await _apiService.get(
      '/student-registration-requests/',
      queryParameters: queryParams,
    );

    return (response.data as List)
        .map((json) => StudentRegistrationRequest.fromJson(json))
        .toList();
  }

  /// Get single registration request
  Future<StudentRegistrationRequest> getRequest(int requestId) async {
    final response = await _apiService.get(
      '/student-registration-requests/$requestId',
    );

    return StudentRegistrationRequest.fromJson(response.data);
  }

  /// Update registration request status (approve/reject)
  Future<StudentRegistrationRequest> updateRequestStatus({
    required int requestId,
    required int ownerId,
    required String status, // "approved" or "rejected"
    String? reviewNotes,
  }) async {
    final response = await _apiService.put(
      '/student-registration-requests/$requestId',
      data: {
        'status': status,
        'review_notes': reviewNotes,
      },
      queryParameters: {'owner_id': ownerId.toString()},
    );

    return StudentRegistrationRequest.fromJson(response.data);
  }

  /// Check registration status by email (for students)
  Future<Map<String, dynamic>> checkStatus(String email) async {
    final response = await _apiService.get(
      '/students/check-registration-status/$email',
    );

    return response.data;
  }
}
