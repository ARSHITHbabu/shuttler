import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/schedule.dart';

/// Service for schedule (session) API operations
class ScheduleService {
  final ApiService _apiService;

  ScheduleService(this._apiService);

  /// Get all schedules
  /// Backend doesn't have GET /schedules/, only:
  /// - GET /schedules/batch/{batch_id}
  /// - GET /schedules/date/{date}
  Future<List<Schedule>> getSchedules({
    String? sessionType,
    DateTime? startDate,
    DateTime? endDate,
    int? batchId,
  }) async {
    try {
      List<Schedule> allSchedules = [];
      
      // If batchId is provided, use batch endpoint
      if (batchId != null) {
        try {
          final response = await _apiService.get(
            '/schedules/batch/$batchId',
          );
          if (response.data is List) {
            final batchSchedules = (response.data as List)
                .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
                .toList();
            allSchedules.addAll(batchSchedules);
          }
        } catch (e) {
          // Silently fail for individual batch
        }
      }
      
      // If date is provided, use date endpoint
      if (startDate != null) {
        try {
          final dateStr = startDate.toIso8601String().split('T')[0];
          final response = await _apiService.get(
            '/schedules/date/$dateStr',
          );
          if (response.data is List) {
            final dateSchedules = (response.data as List)
                .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
                .toList();
            // Merge with existing schedules, avoiding duplicates
            for (var schedule in dateSchedules) {
              if (!allSchedules.any((s) => s.id == schedule.id)) {
                allSchedules.add(schedule);
              }
            }
          }
        } catch (e) {
          // Silently fail for individual date
        }
      }
      
      // If no filters provided, try to get schedules for all batches
      // This is a workaround since backend doesn't have GET /schedules/
      if (batchId == null && startDate == null) {
        // Return empty list - caller should provide batchId or date
        // Alternatively, we could fetch all batches and get their schedules
        return [];
      }
      
      return allSchedules;
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
  /// NOTE: Backend currently doesn't have a PUT endpoint for schedules.
  /// This will fail with a 405 Method Not Allowed error until backend adds the endpoint.
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
