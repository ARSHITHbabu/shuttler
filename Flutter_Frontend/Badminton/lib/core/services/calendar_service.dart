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
      // Clean the data: remove null values and ensure proper types
      final cleanedData = <String, dynamic>{};
      eventData.forEach((key, value) {
        if (value != null) {
          // Ensure created_by is an integer
          if (key == 'created_by') {
            cleanedData[key] = value is int ? value : int.tryParse(value.toString()) ?? value;
          } else {
            cleanedData[key] = value;
          }
        }
      });

      // Validate required fields
      if (!cleanedData.containsKey('title') || cleanedData['title'] == null || cleanedData['title'].toString().trim().isEmpty) {
        throw Exception('Event title is required');
      }
      if (!cleanedData.containsKey('event_type') || cleanedData['event_type'] == null) {
        throw Exception('Event type is required');
      }
      if (!cleanedData.containsKey('date') || cleanedData['date'] == null) {
        throw Exception('Event date is required');
      }
      if (!cleanedData.containsKey('created_by') || cleanedData['created_by'] == null) {
        throw Exception('Created by user ID is required');
      }

      final response = await _apiService.post(
        ApiEndpoints.calendarEvents,
        data: cleanedData,
      );
      return CalendarEvent.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create calendar event: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update a calendar event
  Future<CalendarEvent> updateCalendarEvent(int id, Map<String, dynamic> eventData) async {
    try {
      // Clean the data: remove null values and ensure proper types
      final cleanedData = <String, dynamic>{};
      eventData.forEach((key, value) {
        if (value != null) {
          // Ensure created_by is an integer if present
          if (key == 'created_by') {
            cleanedData[key] = value is int ? value : int.tryParse(value.toString()) ?? value;
          } else {
            cleanedData[key] = value;
          }
        }
      });

      final response = await _apiService.put(
        ApiEndpoints.calendarEventById(id),
        data: cleanedData,
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
