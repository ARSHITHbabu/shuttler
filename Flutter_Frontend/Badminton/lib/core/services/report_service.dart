import 'package:dio/dio.dart';
import 'api_service.dart';

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  Future<Map<String, dynamic>> generateReport({
    required String type, // 'attendance', 'fee', 'performance'
    required String filterType, // 'season', 'year', 'month'
    required String filterValue,
    required String batchId,
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
}
