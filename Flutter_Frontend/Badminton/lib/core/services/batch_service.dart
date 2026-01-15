import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/batch.dart';
import '../../models/student.dart';

/// Service for batch-related API operations
class BatchService {
  final ApiService _apiService;

  BatchService(this._apiService);

  /// Get all batches
  Future<List<Batch>> getBatches({String? status}) async {
    try {
      // Backend doesn't support status filter in query params
      final response = await _apiService.get(ApiEndpoints.batches);
      
      if (response.data is List) {
        final batches = (response.data as List)
            .map((json) => Batch.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Filter by status if provided (client-side filtering)
        if (status != null) {
          // Note: Backend doesn't have status field, so we'll return all
          // You may need to add status filtering logic based on your needs
          return batches;
        }
        
        return batches;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch batches: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get batches assigned to a specific coach
  Future<List<Batch>> getBatchesByCoachId(int coachId) async {
    try {
      // Backend endpoint: GET /batches/coach/{coach_id}
      final response = await _apiService.get('/batches/coach/$coachId');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Batch.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch coach batches: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get batch by ID
  Future<Batch> getBatchById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.batchById(id));
      return Batch.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch batch: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new batch
  Future<Batch> createBatch(Map<String, dynamic> batchData) async {
    try {
      // Map Flutter model fields to backend fields
      final backendData = {
        'batch_name': batchData['name'] ?? batchData['batch_name'],
        'timing': batchData['timing'] ?? '${batchData['start_time']} - ${batchData['end_time']}',
        'period': batchData['period'] ?? (batchData['days'] as List<String>?)?.join(',') ?? '',
        'capacity': batchData['capacity'],
        'fees': batchData['fees'] ?? '0',
        'start_date': batchData['start_date'] ?? DateTime.now().toIso8601String().split('T')[0],
        'assigned_coach_id': batchData['coach_id'] ?? batchData['assigned_coach_id'],
        'assigned_coach_name': batchData['coach_name'] ?? batchData['assigned_coach_name'],
        'location': batchData['location'],
        'created_by': batchData['created_by'] ?? 'owner', // TODO: Get from auth
      };
      
      final response = await _apiService.post(
        ApiEndpoints.batches,
        data: backendData,
      );
      return Batch.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create batch: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a batch
  Future<Batch> updateBatch(int id, Map<String, dynamic> batchData) async {
    try {
      // Map Flutter model fields to backend fields
      final backendData = <String, dynamic>{};
      if (batchData.containsKey('name') || batchData.containsKey('batch_name')) {
        backendData['batch_name'] = batchData['name'] ?? batchData['batch_name'];
      }
      if (batchData.containsKey('timing')) {
        backendData['timing'] = batchData['timing'];
      } else if (batchData.containsKey('start_time') || batchData.containsKey('end_time')) {
        backendData['timing'] = '${batchData['start_time']} - ${batchData['end_time']}';
      }
      if (batchData.containsKey('period')) {
        backendData['period'] = batchData['period'];
      } else if (batchData.containsKey('days')) {
        backendData['period'] = (batchData['days'] as List<String>?)?.join(',') ?? '';
      }
      if (batchData.containsKey('capacity')) {
        backendData['capacity'] = batchData['capacity'];
      }
      if (batchData.containsKey('fees')) {
        backendData['fees'] = batchData['fees'];
      }
      if (batchData.containsKey('location')) {
        backendData['location'] = batchData['location'];
      }
      if (batchData.containsKey('coach_id') || batchData.containsKey('assigned_coach_id')) {
        backendData['assigned_coach_id'] = batchData['coach_id'] ?? batchData['assigned_coach_id'];
      }
      if (batchData.containsKey('coach_name') || batchData.containsKey('assigned_coach_name')) {
        backendData['assigned_coach_name'] = batchData['coach_name'] ?? batchData['assigned_coach_name'];
      }
      
      final response = await _apiService.put(
        ApiEndpoints.batchById(id),
        data: backendData,
      );
      return Batch.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update batch: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a batch
  Future<void> deleteBatch(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.batchById(id));
    } catch (e) {
      throw Exception('Failed to delete batch: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get students enrolled in a batch
  Future<List<Student>> getBatchStudents(int batchId) async {
    try {
      // Backend uses: GET /batches/{batch_id}/students
      final response = await _apiService.get('/batches/$batchId/students');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Student.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch batch students: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Enroll a student in a batch
  Future<void> enrollStudent(int batchId, int studentId) async {
    try {
      // Backend uses: POST /batches/{batch_id}/students/{student_id}
      await _apiService.post(
        '/batches/$batchId/students/$studentId',
      );
    } catch (e) {
      throw Exception('Failed to enroll student: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Remove a student from a batch
  Future<void> removeStudent(int batchId, int studentId) async {
    try {
      // Backend uses: DELETE /batches/{batch_id}/students/{student_id}
      await _apiService.delete('/batches/$batchId/students/$studentId');
    } catch (e) {
      throw Exception('Failed to remove student: ${_apiService.getErrorMessage(e)}');
    }
  }
}
