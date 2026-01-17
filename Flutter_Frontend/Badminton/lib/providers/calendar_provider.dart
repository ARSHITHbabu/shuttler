import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/calendar_event.dart';
import 'service_providers.dart';

part 'calendar_provider.g.dart';

/// Provider for calendar events by date range
@riverpod
Future<List<CalendarEvent>> calendarEvents(
  CalendarEventsRef ref, {
  DateTime? startDate,
  DateTime? endDate,
  String? eventType,
}) async {
  final calendarService = ref.watch(calendarServiceProvider);
  return calendarService.getCalendarEvents(
    startDate: startDate,
    endDate: endDate,
    eventType: eventType,
  );
}

/// Provider for calendar events by specific date
@riverpod
Future<List<CalendarEvent>> calendarEventByDate(
  CalendarEventByDateRef ref,
  DateTime date,
) async {
  final calendarService = ref.watch(calendarServiceProvider);
  // Get events for the specific date
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
  
  return calendarService.getCalendarEvents(
    startDate: startOfDay,
    endDate: endOfDay,
  );
}

/// Provider for calendar events by type
@riverpod
Future<List<CalendarEvent>> calendarEventByType(
  CalendarEventByTypeRef ref,
  String eventType,
) async {
  final calendarService = ref.watch(calendarServiceProvider);
  return calendarService.getCalendarEvents(eventType: eventType);
}

/// Provider for calendar event by ID
@riverpod
Future<CalendarEvent> calendarEventById(CalendarEventByIdRef ref, int id) async {
  final calendarService = ref.watch(calendarServiceProvider);
  return calendarService.getCalendarEventById(id);
}

/// Provider class for calendar CRUD operations
@riverpod
class CalendarEventList extends _$CalendarEventList {
  @override
  Future<List<CalendarEvent>> build({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) async {
    final calendarService = ref.watch(calendarServiceProvider);
    return calendarService.getCalendarEvents(
      startDate: startDate,
      endDate: endDate,
      eventType: eventType,
    );
  }

  /// Create a new calendar event
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      final calendarService = ref.read(calendarServiceProvider);
      await calendarService.createCalendarEvent(eventData);
      
      // Invalidate related providers
      final eventType = eventData['event_type'] as String?;
      if (eventType != null) {
        ref.invalidate(calendarEventByTypeProvider(eventType));
      }
      
      // Invalidate date-based providers if date is provided
      if (eventData['date'] != null) {
        try {
          final date = DateTime.parse(eventData['date'].toString());
          ref.invalidate(calendarEventByDateProvider(date));
        } catch (e) {
          // Date parsing failed, skip invalidation
        }
      }
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to create calendar event: $e');
    }
  }

  /// Update a calendar event
  Future<void> updateEvent(int id, Map<String, dynamic> eventData) async {
    try {
      final calendarService = ref.read(calendarServiceProvider);
      final existing = await calendarService.getCalendarEventById(id);
      await calendarService.updateCalendarEvent(id, eventData);
      
      // Invalidate related providers
      ref.invalidate(calendarEventByIdProvider(id));
      ref.invalidate(calendarEventByTypeProvider(existing.eventType));
      ref.invalidate(calendarEventByDateProvider(existing.date));
      
      // If event type or date changed, invalidate those too
      if (eventData.containsKey('event_type')) {
        ref.invalidate(calendarEventByTypeProvider(eventData['event_type'] as String));
      }
      if (eventData.containsKey('date')) {
        try {
          final date = DateTime.parse(eventData['date'].toString());
          ref.invalidate(calendarEventByDateProvider(date));
        } catch (e) {
          // Date parsing failed, skip invalidation
        }
      }
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to update calendar event: $e');
    }
  }

  /// Delete a calendar event
  Future<void> deleteEvent(int id) async {
    try {
      final calendarService = ref.read(calendarServiceProvider);
      final existing = await calendarService.getCalendarEventById(id);
      await calendarService.deleteCalendarEvent(id);
      
      // Invalidate related providers
      ref.invalidate(calendarEventByIdProvider(id));
      ref.invalidate(calendarEventByTypeProvider(existing.eventType));
      ref.invalidate(calendarEventByDateProvider(existing.date));
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete calendar event: $e');
    }
  }

  /// Refresh calendar event list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final calendarService = ref.read(calendarServiceProvider);
      return calendarService.getCalendarEvents();
    });
  }
}
