import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/performance.dart';

/// Service for performance tracking API operations
class PerformanceService {
  final ApiService _apiService;

  PerformanceService(this._apiService);

  /// Get performance records for a student
  Future<List<Performance>> getPerformanceRecords({
    int? studentId,
    int? batchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (studentId != null) {
        queryParams['student_id'] = studentId;
      }
      if (batchId != null) {
        queryParams['batch_id'] = batchId;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        ApiEndpoints.performance,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Performance.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch performance records: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get performance record by ID
  Future<Performance> getPerformanceById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.performanceById(id));
      return Performance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch performance record: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new performance record
  Future<Performance> createPerformance(Map<String, dynamic> performanceData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.performance,
        data: performanceData,
      );
      return Performance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create performance record: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a performance record
  Future<Performance> updatePerformance(int id, Map<String, dynamic> performanceData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.performanceById(id),
        data: performanceData,
      );
      return Performance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update performance record: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a performance record
  Future<void> deletePerformance(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.performanceById(id));
    } catch (e) {
      throw Exception('Failed to delete performance record: ${_apiService.getErrorMessage(e)}');
    }
  }
}
