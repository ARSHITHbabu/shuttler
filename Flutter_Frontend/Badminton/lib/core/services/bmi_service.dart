import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/bmi_record.dart';

/// Service for BMI tracking API operations
class BMIService {
  final ApiService _apiService;

  BMIService(this._apiService);

  /// Get BMI records for a student
  Future<List<BMIRecord>> getBMIRecords({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (studentId != null) {
        queryParams['student_id'] = studentId;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        ApiEndpoints.bmiRecords,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => BMIRecord.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch BMI records: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get BMI record by ID
  Future<BMIRecord> getBMIRecordById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.bmiRecordById(id));
      return BMIRecord.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch BMI record: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new BMI record
  Future<BMIRecord> createBMIRecord(Map<String, dynamic> bmiData) async {
    try {
      // Calculate BMI if not provided
      if (!bmiData.containsKey('bmi') && bmiData.containsKey('height') && bmiData.containsKey('weight')) {
        final height = (bmiData['height'] as num).toDouble();
        final weight = (bmiData['weight'] as num).toDouble();
        bmiData['bmi'] = BMIRecord.calculateBMI(height, weight);
        bmiData['health_status'] = BMIRecord.getHealthStatus(bmiData['bmi']);
      }

      final response = await _apiService.post(
        ApiEndpoints.bmiRecords,
        data: bmiData,
      );
      return BMIRecord.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create BMI record: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a BMI record
  Future<BMIRecord> updateBMIRecord(int id, Map<String, dynamic> bmiData) async {
    try {
      // Recalculate BMI if height or weight changed
      if (bmiData.containsKey('height') || bmiData.containsKey('weight')) {
        // Need to get existing record first to get missing field
        final existing = await getBMIRecordById(id);
        final height = (bmiData['height'] as num?)?.toDouble() ?? existing.height;
        final weight = (bmiData['weight'] as num?)?.toDouble() ?? existing.weight;
        bmiData['bmi'] = BMIRecord.calculateBMI(height, weight);
        bmiData['health_status'] = BMIRecord.getHealthStatus(bmiData['bmi']);
      }

      final response = await _apiService.put(
        ApiEndpoints.bmiRecordById(id),
        data: bmiData,
      );
      return BMIRecord.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update BMI record: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a BMI record
  Future<void> deleteBMIRecord(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.bmiRecordById(id));
    } catch (e) {
      throw Exception('Failed to delete BMI record: ${_apiService.getErrorMessage(e)}');
    }
  }
}
