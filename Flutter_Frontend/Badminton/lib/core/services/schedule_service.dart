import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/schedule.dart';

/// Service for schedule (session) API operations
class ScheduleService {
  final ApiService _apiService;

  ScheduleService(this._apiService);

  /// Get all schedules
  Future<List<Schedule>> getSchedules({
    String? sessionType,
    DateTime? startDate,
    DateTime? endDate,
    int? batchId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (sessionType != null) {
        queryParams['session_type'] = sessionType;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      if (batchId != null) {
        queryParams['batch_id'] = batchId;
      }

      final response = await _apiService.get(
        ApiEndpoints.schedules,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch schedules: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get schedule by ID
  Future<Schedule> getScheduleById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.scheduleById(id));
      return Schedule.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch schedule: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new schedule
  Future<Schedule> createSchedule(Map<String, dynamic> scheduleData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.schedules,
        data: scheduleData,
      );
      return Schedule.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create schedule: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a schedule
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> scheduleData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.scheduleById(id),
        data: scheduleData,
      );
      return Schedule.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update schedule: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.scheduleById(id));
    } catch (e) {
      throw Exception('Failed to delete schedule: ${_apiService.getErrorMessage(e)}');
    }
  }
}
