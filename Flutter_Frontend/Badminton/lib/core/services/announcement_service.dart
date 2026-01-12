import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/announcement.dart';

/// Service for announcement API operations
class AnnouncementService {
  final ApiService _apiService;

  AnnouncementService(this._apiService);

  /// Get all announcements
  Future<List<Announcement>> getAnnouncements({
    String? targetAudience,
    String? priority,
    bool? isSent,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (targetAudience != null) {
        queryParams['target_audience'] = targetAudience;
      }
      if (priority != null) {
        queryParams['priority'] = priority;
      }
      if (isSent != null) {
        queryParams['is_sent'] = isSent;
      }

      final response = await _apiService.get(
        ApiEndpoints.announcements,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch announcements: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get announcement by ID
  Future<Announcement> getAnnouncementById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.announcementById(id));
      return Announcement.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch announcement: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new announcement
  Future<Announcement> createAnnouncement(Map<String, dynamic> announcementData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.announcements,
        data: announcementData,
      );
      return Announcement.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create announcement: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update an announcement
  Future<Announcement> updateAnnouncement(int id, Map<String, dynamic> announcementData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.announcementById(id),
        data: announcementData,
      );
      return Announcement.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update announcement: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete an announcement
  Future<void> deleteAnnouncement(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.announcementById(id));
    } catch (e) {
      throw Exception('Failed to delete announcement: ${_apiService.getErrorMessage(e)}');
    }
  }
}
