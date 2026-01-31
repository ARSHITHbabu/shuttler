import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/request.dart';

/// Service for request-related API operations
class RequestService {
  final ApiService _apiService;

  RequestService(this._apiService);

  /// Get all requests with optional filters
  Future<List<Request>> getRequests({
    String? requestType,
    String? status,
    String? requesterType,
    int? requesterId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (requestType != null) queryParams['request_type'] = requestType;
      if (status != null) queryParams['status'] = status;
      if (requesterType != null) queryParams['requester_type'] = requesterType;
      if (requesterId != null) queryParams['requester_id'] = requesterId;

      final response = await _apiService.get(
        ApiEndpoints.requests,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Request.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch requests: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get request by ID
  Future<Request> getRequestById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.requestById(id));
      return Request.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new request
  Future<Request> createRequest({
    required String requestType,
    required String requesterType,
    required int requesterId,
    required String title,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.requests,
        data: {
          'request_type': requestType,
          'requester_type': requesterType,
          'requester_id': requesterId,
          'title': title,
          'description': description,
          'metadata': metadata,
        },
      );
      return Request.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Approve a request
  Future<Request> approveRequest(int id, {String? responseMessage}) async {
    try {
      final Map<String, dynamic> data = {};
      if (responseMessage != null) {
        data['response_message'] = responseMessage;
      }
      
      final response = await _apiService.put(
        ApiEndpoints.approveRequest(id),
        data: data.isNotEmpty ? data : null,
      );
      return Request.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to approve request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Reject a request
  Future<Request> rejectRequest(int id, {String? responseMessage}) async {
    try {
      final Map<String, dynamic> data = {};
      if (responseMessage != null) {
        data['response_message'] = responseMessage;
      }
      
      final response = await _apiService.put(
        ApiEndpoints.rejectRequest(id),
        data: data.isNotEmpty ? data : null,
      );
      return Request.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to reject request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a request
  Future<Request> updateRequest(
    int id, {
    String? status,
    String? responseMessage,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (status != null) data['status'] = status;
      if (responseMessage != null) data['response_message'] = responseMessage;

      final response = await _apiService.put(
        ApiEndpoints.requestById(id),
        data: data,
      );
      return Request.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Cancel/delete a request
  Future<void> cancelRequest(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.requestById(id));
    } catch (e) {
      throw Exception('Failed to cancel request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get request statistics
  Future<Map<String, dynamic>> getRequestStats() async {
    try {
      final response = await _apiService.get(ApiEndpoints.requestStats);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch request stats: ${_apiService.getErrorMessage(e)}');
    }
  }
}
