import '../constants/api_endpoints.dart';
import 'api_service.dart';

/// Service for invitation-related API operations
class InvitationService {
  final ApiService _apiService;

  InvitationService(this._apiService);

  /// Create a new invitation
  /// Returns invitation data with invite_link
  Future<Map<String, dynamic>> createInvitation({
    required int coachId,
    required String coachName,
    String? studentPhone,
    String? studentEmail,
    int? batchId,
  }) async {
    try {
      // Validate that at least phone or email is provided
      if ((studentPhone == null || studentPhone.trim().isEmpty) &&
          (studentEmail == null || studentEmail.trim().isEmpty)) {
        throw Exception('At least phone number or email address must be provided');
      }

      final response = await _apiService.post(
        ApiEndpoints.invitations,
        data: {
          'coach_id': coachId,
          'coach_name': coachName,
          if (studentPhone != null && studentPhone.trim().isNotEmpty)
            'student_phone': studentPhone.trim(),
          if (studentEmail != null && studentEmail.trim().isNotEmpty)
            'student_email': studentEmail.trim(),
          'batch_id': ?batchId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create invitation');
      }
    } catch (e) {
      throw Exception('Failed to create invitation: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get invitations for a student by email
  Future<List<Map<String, dynamic>>> getStudentInvitations(String studentEmail) async {
    try {
      final response = await _apiService.get(
        '/invitations/student/$studentEmail',
      );
      if (response.data is List) {
        return (response.data as List)
            .map((json) => json as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch student invitations: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get invitations for a coach
  Future<List<Map<String, dynamic>>> getCoachInvitations(int coachId) async {
    try {
      final response = await _apiService.get(
        '/invitations/coach/$coachId',
      );
      if (response.data is List) {
        return (response.data as List)
            .map((json) => json as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch coach invitations: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get all pending invitations (owner view)
  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    try {
      final response = await _apiService.get('/invitations/pending');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => json as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch pending invitations: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update invitation status (approved/rejected)
  Future<Map<String, dynamic>> updateInvitationStatus(
    int invitationId,
    String status,
  ) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.invitationById(invitationId),
        data: {'status': status},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update invitation: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a coach invitation (sent by owner)
  /// Returns invitation data with invite_link
  Future<Map<String, dynamic>> createCoachInvitation({
    required int ownerId,
    required String ownerName,
    String? coachName,
    String? coachPhone,
    String? coachEmail,
    int? experienceYears,
  }) async {
    try {
      // Validate that at least phone or email is provided
      if ((coachPhone == null || coachPhone.trim().isEmpty) &&
          (coachEmail == null || coachEmail.trim().isEmpty)) {
        throw Exception('At least phone number or email address must be provided');
      }

      final response = await _apiService.post(
        '/coach-invitations/',
        data: {
          'owner_id': ownerId,
          'owner_name': ownerName,
          if (coachName != null && coachName.trim().isNotEmpty)
            'coach_name': coachName.trim(),
          if (coachPhone != null && coachPhone.trim().isNotEmpty)
            'coach_phone': coachPhone.trim(),
          if (coachEmail != null && coachEmail.trim().isNotEmpty)
            'coach_email': coachEmail.trim(),
          'experience_years': ?experienceYears,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create coach invitation');
      }
    } catch (e) {
      throw Exception('Failed to create coach invitation: ${_apiService.getErrorMessage(e)}');
    }
  }
}
