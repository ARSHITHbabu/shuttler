import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/owner.dart';

/// Service for owner-related API operations
class OwnerService {
  final ApiService _apiService;

  OwnerService(this._apiService);

  /// Get all owners
  Future<List<Owner>> getOwners() async {
    try {
      final response = await _apiService.get(ApiEndpoints.owners);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Owner.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch owners: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get owner by ID
  Future<Owner> getOwnerById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.ownerById(id));
      return Owner.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch owner: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new owner
  Future<Owner> createOwner(Map<String, dynamic> ownerData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.owners,
        data: ownerData,
      );
      return Owner.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create owner: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update an owner
  Future<Owner> updateOwner(int id, Map<String, dynamic> ownerData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.ownerById(id),
        data: ownerData,
      );
      return Owner.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update owner: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete an owner
  Future<void> deleteOwner(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.ownerById(id));
    } catch (e) {
      throw Exception('Failed to delete owner: ${_apiService.getErrorMessage(e)}');
    }
  }
}
