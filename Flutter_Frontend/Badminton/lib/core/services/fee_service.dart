import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/fee.dart';

/// Service for fee-related API operations
class FeeService {
  final ApiService _apiService;

  FeeService(this._apiService);

  /// Get all fees
  Future<List<Fee>> getFees({
    int? studentId,
    int? batchId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Backend uses different endpoints: /fees/student/{student_id} or /fees/batch/{batch_id}
      if (studentId != null) {
        final response = await _apiService.get('/fees/student/$studentId');
        if (response.data is List) {
          return (response.data as List)
              .map((json) => Fee.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else if (batchId != null) {
        final response = await _apiService.get('/fees/batch/$batchId');
        if (response.data is List) {
          return (response.data as List)
              .map((json) => Fee.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      }

      // If no filters, we can't get all fees from backend
      // Return empty list or throw error
      return [];
    } catch (e) {
      throw Exception('Failed to fetch fees: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get fee by ID
  Future<Fee> getFeeById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.feeById(id));
      return Fee.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch fee: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new fee record
  Future<Fee> createFee(Map<String, dynamic> feeData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.fees,
        data: feeData,
      );
      return Fee.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create fee: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a fee record (e.g., mark as paid)
  Future<Fee> updateFee(int id, Map<String, dynamic> feeData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.feeById(id),
        data: feeData,
      );
      return Fee.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update fee: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Record payment for a fee
  Future<Fee> recordPayment({
    required int feeId,
    required String paymentMethod,
    DateTime? paidDate,
    String? remarks,
  }) async {
    try {
      return await updateFee(feeId, {
        'status': 'paid',
        'payment_method': paymentMethod,
        'paid_date': paidDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'remarks': remarks,
      });
    } catch (e) {
      throw Exception('Failed to record payment: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Calculate total pending fees
  Future<double> getTotalPendingFees() async {
    try {
      // Backend doesn't have a "get all fees" endpoint
      // We'll need to get fees by batch or student
      // For now, return 0 or implement a different approach
      // TODO: Implement proper pending fees calculation
      return 0.0;
    } catch (e) {
      throw Exception('Failed to calculate pending fees: ${_apiService.getErrorMessage(e)}');
    }
  }
}
