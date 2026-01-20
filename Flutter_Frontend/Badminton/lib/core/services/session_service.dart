import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/session.dart';

/// Service for session/season API operations
class SessionService {
  final ApiService _apiService;

  SessionService(this._apiService);

  /// Get all sessions, optionally filtered by status
  Future<List<Session>> getSessions({String? status}) async {
    try {
      String endpoint = ApiEndpoints.sessions;
      if (status != null) {
        endpoint += '?status=$status';
      }
      final response = await _apiService.get(endpoint);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Session.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sessions: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get session by ID
  Future<Session> getSessionById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.sessionById(id));
      return Session.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch session: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new session
  Future<Session> createSession(Map<String, dynamic> sessionData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.sessions,
        data: sessionData,
      );
      return Session.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create session: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a session
  Future<Session> updateSession(int id, Map<String, dynamic> sessionData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.sessionById(id),
        data: sessionData,
      );
      return Session.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update session: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a session
  Future<void> deleteSession(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.sessionById(id));
    } catch (e) {
      throw Exception('Failed to delete session: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get all batches assigned to a session
  Future<List<dynamic>> getSessionBatches(int sessionId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.sessionBatches(sessionId));
      if (response.data is List) {
        return response.data as List;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch session batches: ${_apiService.getErrorMessage(e)}');
    }
  }
}
