import 'package:dio/dio.dart';
import 'api_service.dart';

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  Future<Map<String, dynamic>> generateReport({
    required String type, // 'attendance', 'fee', 'performance'
    required String filterType, // 'season', 'year', 'month'
    required String filterValue,
    String? batchId,
    String? generatedByName,
    String? generatedByRole,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/reports/generate',
        data: {
          'type': type,
          'filter_type': filterType,
          'filter_value': filterValue,
          'batch_id': batchId,
          'generated_by_name': generatedByName,
          'generated_by_role': generatedByRole,
        },
      );
      
      // Handle Dio response or generic response
      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to generate report');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveReportHistory({
    required String reportType,
    required String filterSummary,
    required Map<String, dynamic> reportData,
    required int userId,
    required String userRole,
    Map<String, dynamic>? keyMetrics,
  }) async {
    try {
      await _apiService.post(
        '/api/reports/history',
        data: {
          'report_type': reportType,
          'filter_summary': filterSummary,
          'report_data': reportData,
          'key_metrics': keyMetrics,
          'user_id': userId,
          'user_role': userRole,
        },
      );
    } catch (e) {
      // Don't rethrow, just log error so UI doesn't break if history save fails
      print("Error saving report history: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getReportHistory({
    required int userId, 
    required String userRole,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/reports/history',
        queryParameters: {
          'user_id': userId,
          'user_role': userRole,
        },
      );
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
