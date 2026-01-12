import 'dart:io';
import 'dart:convert';
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
      // #region agent log
      try {
        final logFile = File(r'd:\laptop new\f\Personal Projects\badminton\abhi_colab\Shuttler_Cursor\shuttler\.cursor\debug.log');
        final logEntry = jsonEncode({
          'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'location': 'bmi_service.dart:56',
          'message': 'createBMIRecord entry - data before processing',
          'data': {'bmiData': bmiData, 'hasBmi': bmiData.containsKey('bmi'), 'hasHealthStatus': bmiData.containsKey('health_status'), 'hasRecordedBy': bmiData.containsKey('recorded_by')},
          'sessionId': 'debug-session',
          'runId': 'run1',
          'hypothesisId': 'A'
        });
        await logFile.writeAsString('$logEntry\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion

      // Create a copy of bmiData to avoid mutating the original
      final requestData = Map<String, dynamic>.from(bmiData);
      
      // Remove bmi and health_status - backend calculates these
      requestData.remove('bmi');
      requestData.remove('health_status');
      
      // Add recorded_by if not provided (required by backend)
      if (!requestData.containsKey('recorded_by')) {
        requestData['recorded_by'] = 'Owner'; // Default to Owner, can be overridden
      }

      // #region agent log
      try {
        final logFile = File(r'd:\laptop new\f\Personal Projects\badminton\abhi_colab\Shuttler_Cursor\shuttler\.cursor\debug.log');
        final logEntry = jsonEncode({
          'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'location': 'bmi_service.dart:66',
          'message': 'createBMIRecord - data before POST request (after fix)',
          'data': {'requestData': requestData, 'keys': requestData.keys.toList()},
          'sessionId': 'debug-session',
          'runId': 'run1',
          'hypothesisId': 'B'
        });
        await logFile.writeAsString('$logEntry\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion

      final response = await _apiService.post(
        ApiEndpoints.bmiRecords,
        data: requestData,
      );
      return BMIRecord.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // #region agent log
      try {
        final logFile = File(r'd:\laptop new\f\Personal Projects\badminton\abhi_colab\Shuttler_Cursor\shuttler\.cursor\debug.log');
        final errorMsg = _apiService.getErrorMessage(e);
        final logEntry = jsonEncode({
          'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'location': 'bmi_service.dart:72',
          'message': 'createBMIRecord error',
          'data': {'error': e.toString(), 'errorMessage': errorMsg},
          'sessionId': 'debug-session',
          'runId': 'run1',
          'hypothesisId': 'C'
        });
        await logFile.writeAsString('$logEntry\n', mode: FileMode.append);
      } catch (_) {}
      // #endregion
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
