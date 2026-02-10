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
      final Map<String, dynamic> queryParams = {};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        ApiEndpoints.batches,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response.data is List) {
        final batches = (response.data as List)
            .map((json) => Batch.fromJson(json as Map<String, dynamic>))
            .toList();
        
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
      final backendData = <String, dynamic>{
        'batch_name': batchData['name'] ?? batchData['batch_name'],
        'timing': batchData['timing'] ?? '${batchData['start_time']} - ${batchData['end_time']}',
        'period': batchData['period'] ?? (batchData['days'] as List<String>?)?.join(',') ?? '',
        'capacity': batchData['capacity'],
        'fees': batchData['fees'] ?? '0',
        'start_date': batchData['start_date'] ?? DateTime.now().toIso8601String().split('T')[0],
        'location': batchData['location'],
        'created_by': batchData['created_by'] ?? 'owner', // TODO: Get from auth
      };
      
      // Handle coach assignments - support multiple coaches
      if (batchData.containsKey('assigned_coach_ids')) {
        final coachIds = batchData['assigned_coach_ids'];
        if (coachIds is List && coachIds.isNotEmpty) {
          backendData['assigned_coach_ids'] = coachIds;
        }
      } else if (batchData.containsKey('coach_id') || batchData.containsKey('assigned_coach_id')) {
        // Backward compatibility: convert single coach to array
        final coachId = batchData['coach_id'] ?? batchData['assigned_coach_id'];
        if (coachId != null) {
          backendData['assigned_coach_ids'] = [coachId];
        }
      }
      
      // Handle session_id
      if (batchData.containsKey('session_id')) {
        backendData['session_id'] = batchData['session_id'];
      }
      
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
      if (batchData.containsKey('start_date')) {
        backendData['start_date'] = batchData['start_date'];
      }
      if (batchData.containsKey('location')) {
        backendData['location'] = batchData['location'];
      }
      
      // Handle session_id
      if (batchData.containsKey('session_id')) {
        backendData['session_id'] = batchData['session_id'];
      }
      
      // Handle coach assignments - support multiple coaches (new format)
      if (batchData.containsKey('assigned_coach_ids')) {
        final coachIds = batchData['assigned_coach_ids'];
        if (coachIds is List) {
          // Send as array for multiple coaches
          backendData['assigned_coach_ids'] = coachIds;
        } else if (coachIds != null) {
          // If it's a single value, convert to array
          backendData['assigned_coach_ids'] = [coachIds];
        } else {
          // Empty array means no coaches
          backendData['assigned_coach_ids'] = [];
        }
      } else if (batchData.containsKey('coach_id') || batchData.containsKey('assigned_coach_id')) {
        // Backward compatibility: convert single coach to array
        final coachId = batchData['coach_id'] ?? batchData['assigned_coach_id'];
        if (coachId != null) {
          backendData['assigned_coach_ids'] = [coachId];
        } else {
          backendData['assigned_coach_ids'] = [];
        }
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

  /// Delete a batch (Soft delete - logic varies, we use deactivate for soft delete)
  Future<void> deleteBatch(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.batchById(id));
    } catch (e) {
      throw Exception('Failed to delete batch: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Deactivate a batch (Soft delete)
  Future<void> deactivateBatch(int id) async {
    try {
      await _apiService.post(ApiEndpoints.deactivateBatch(id));
    } catch (e) {
      throw Exception('Failed to deactivate batch: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Remove a batch permanently (Hard delete)
  Future<void> removeBatchPermanently(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.removeBatch(id));
    } catch (e) {
      throw Exception('Failed to remove batch permanently: ${_apiService.getErrorMessage(e)}');
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

  /// Get all batches that a student is enrolled in
  Future<List<Batch>> getStudentBatches(int studentId) async {
    try {
      // Backend uses: GET /student-batches/{student_id}
      final response = await _apiService.get('/student-batches/$studentId');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Batch.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch student batches: ${_apiService.getErrorMessage(e)}');
    }
  }
}
