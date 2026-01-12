import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/calendar_event.dart';

/// Service for calendar event API operations
class CalendarService {
  final ApiService _apiService;

  CalendarService(this._apiService);

  /// Get calendar events
  Future<List<CalendarEvent>> getCalendarEvents({
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (eventType != null) {
        queryParams['event_type'] = eventType;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        ApiEndpoints.calendarEvents,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => CalendarEvent.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch calendar events: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get calendar event by ID
  Future<CalendarEvent> getCalendarEventById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.calendarEventById(id));
      return CalendarEvent.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch calendar event: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new calendar event
  Future<CalendarEvent> createCalendarEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.calendarEvents,
        data: eventData,
      );
      return CalendarEvent.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create calendar event: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a calendar event
  Future<CalendarEvent> updateCalendarEvent(int id, Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.calendarEventById(id),
        data: eventData,
      );
      return CalendarEvent.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update calendar event: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a calendar event
  Future<void> deleteCalendarEvent(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.calendarEventById(id));
    } catch (e) {
      throw Exception('Failed to delete calendar event: ${_apiService.getErrorMessage(e)}');
    }
  }
}
