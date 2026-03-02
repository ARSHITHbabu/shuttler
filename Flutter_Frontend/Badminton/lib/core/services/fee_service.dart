import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/fee.dart';
import '../../models/fee_payment.dart';

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
      // Use the new unified endpoint with query parameters
      final queryParams = <String, dynamic>{};
      if (studentId != null) {
        queryParams['student_id'] = studentId;
      }
      if (batchId != null) {
        queryParams['batch_id'] = batchId;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        ApiEndpoints.fees,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Fee.fromJson(json as Map<String, dynamic>))
            .toList();
      }
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

  /// Get all payments for a fee
  Future<List<FeePayment>> getFeePayments(int feeId) async {
    try {
      final response = await _apiService.get('/fees/$feeId/payments/');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => FeePayment.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch fee payments: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a payment for a fee
  Future<FeePayment> createFeePayment(int feeId, Map<String, dynamic> paymentData) async {
    try {
      final response = await _apiService.post(
        '/fees/$feeId/payments/',
        data: paymentData,
      );
      return FeePayment.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create payment: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a payment
  Future<void> deleteFeePayment(int feeId, int paymentId) async {
    try {
      await _apiService.delete('/fees/$feeId/payments/$paymentId');
    } catch (e) {
      throw Exception('Failed to delete payment: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Notify student about overdue fee
  Future<void> notifyStudent(int feeId) async {
    try {
      await _apiService.post('/fees/$feeId/notify');
    } catch (e) {
      throw Exception('Failed to notify student: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Calculate total pending fees
  Future<double> getTotalPendingFees() async {
    try {
      // Get all fees with 'pending' status
      final pendingFees = await getFees(status: 'pending');
      
      // Get all fees with 'overdue' status
      final overdueFees = await getFees(status: 'overdue');
      
      // Combine both lists
      final allPendingFees = [...pendingFees, ...overdueFees];
      
      // Sum up all pending amounts
      double totalPending = 0.0;
      for (final fee in allPendingFees) {
        totalPending += fee.pendingAmount;
      }
      
      return totalPending;
    } catch (e) {
      // Return 0 on error to not break the dashboard
      return 0.0;
    }
  }
}
