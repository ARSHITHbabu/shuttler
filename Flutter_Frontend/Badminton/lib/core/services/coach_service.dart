import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/coach.dart';

/// Service for coach-related API operations
class CoachService {
  final ApiService _apiService;

  CoachService(this._apiService);

  /// Get all coaches
  Future<List<Coach>> getCoaches() async {
    try {
      final response = await _apiService.get(ApiEndpoints.coaches);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Coach.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch coaches: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get coach by ID
  Future<Coach> getCoachById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.coachById(id));
      return Coach.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch coach: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new coach
  Future<Coach> createCoach(Map<String, dynamic> coachData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.coaches,
        data: coachData,
      );
      return Coach.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create coach: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a coach
  Future<Coach> updateCoach(int id, Map<String, dynamic> coachData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.coachById(id),
        data: coachData,
      );
      return Coach.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update coach: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a coach
  Future<void> deleteCoach(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.coachById(id));
    } catch (e) {
      throw Exception('Failed to delete coach: ${_apiService.getErrorMessage(e)}');
    }
  }
}
