import 'package:dio/dio.dart';
import 'api_service.dart';
import '../../models/coach_registration_request.dart';

/// Service for coach registration request-related API operations
class CoachRegistrationRequestService {
  final ApiService _apiService;

  CoachRegistrationRequestService(this._apiService);

  /// Create a coach registration request
  Future<CoachRegistrationRequest> createRequest({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? specialization,
    int? experienceYears,
  }) async {
    try {
      final response = await _apiService.post(
        '/coaches/registration-request',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'specialization': specialization,
          'experience_years': experienceYears,
        },
      );

      return CoachRegistrationRequest.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            throw Exception(data['detail']);
          } else if (data.containsKey('message')) {
            throw Exception(data['message']);
          }
        }
      }
      throw Exception('Failed to create coach registration request: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Get all coach registration requests (owner only)
  Future<List<CoachRegistrationRequest>> getRequests({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) {
      queryParams['status'] = status;
    }
    final response = await _apiService.get(
      '/coach-registration-requests/',
      queryParameters: queryParams,
    );

    return (response.data as List)
        .map((json) => CoachRegistrationRequest.fromJson(json))
        .toList();
  }

  /// Get single coach registration request
  Future<CoachRegistrationRequest> getRequest(int requestId) async {
    final response = await _apiService.get(
      '/coach-registration-requests/$requestId',
    );

    return CoachRegistrationRequest.fromJson(response.data);
  }

  /// Update coach registration request status (approve/reject)
  Future<CoachRegistrationRequest> updateRequestStatus({
    required int requestId,
    required int ownerId,
    required String status, // "approved" or "rejected"
    String? reviewNotes,
  }) async {
    final response = await _apiService.put(
      '/coach-registration-requests/$requestId',
      data: {
        'status': status,
        'review_notes': reviewNotes,
      },
      queryParameters: {'owner_id': ownerId.toString()},
    );

    return CoachRegistrationRequest.fromJson(response.data);
  }

  /// Check coach registration status by email
  Future<Map<String, dynamic>> checkStatus(String email) async {
    final response = await _apiService.get(
      '/coaches/check-registration-status/$email',
    );

    return response.data;
  }
}
