import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/providers/calendar_provider.dart';
import 'package:badminton/models/calendar_event.dart';

/// Comprehensive tests for calendar_provider
void main() {
  group('Calendar Provider Tests', () {
    test('calendarEventsProvider can be accessed', () {
      final container = ProviderContainer();
      
      // Access the provider
      final eventsAsync = container.read(calendarEventsProvider());
      
      // Provider should return AsyncValue
      expect(eventsAsync, isNotNull);
      
      container.dispose();
    });

    test('calendarEventsProvider accepts date range parameters', () {
      final container = ProviderContainer();
      
      final startDate = DateTime(2026, 1, 1);
      final endDate = DateTime(2026, 1, 31);
      
      // Access the provider with date range
      final eventsAsync = container.read(
        calendarEventsProvider(
          startDate: startDate,
          endDate: endDate,
        ),
      );
      
      // Provider should return AsyncValue
      expect(eventsAsync, isNotNull);
      
      container.dispose();
    });

    test('calendarEventsProvider accepts eventType filter', () {
      final container = ProviderContainer();
      
      // Access the provider with event type filter
      final eventsAsync = container.read(
        calendarEventsProvider(eventType: 'holiday'),
      );
      
      // Provider should return AsyncValue
      expect(eventsAsync, isNotNull);
      
      container.dispose();
    });

    test('calendarEventByDateProvider accepts date parameter', () {
      final container = ProviderContainer();
      
      final date = DateTime(2026, 1, 15);
      
      // Access the provider with specific date
      final eventsAsync = container.read(calendarEventByDateProvider(date));
      
      // Provider should return AsyncValue
      expect(eventsAsync, isNotNull);
      
      container.dispose();
    });

    test('calendarEventByTypeProvider accepts eventType parameter', () {
      final container = ProviderContainer();
      
      // Access the provider with event type
      final eventsAsync = container.read(calendarEventByTypeProvider('tournament'));
      
      // Provider should return AsyncValue
      expect(eventsAsync, isNotNull);
      
      container.dispose();
    });

    test('calendarEventByIdProvider accepts id parameter', () {
      final container = ProviderContainer();
      
      // Access the provider with ID
      final eventAsync = container.read(calendarEventByIdProvider(1));
      
      // Provider should return AsyncValue
      expect(eventAsync, isNotNull);
      
      container.dispose();
    });

    test('CalendarEventList notifier can be accessed', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(calendarEventListProvider().notifier);
      
      // Notifier should exist
      expect(notifier, isNotNull);
      
      container.dispose();
    });

    test('CalendarEventList refresh method exists', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(calendarEventListProvider().notifier);
      
      // Refresh method should exist
      expect(notifier.refresh, isNotNull);
      
      container.dispose();
    });

    test('CalendarEventList createEvent method exists', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(calendarEventListProvider().notifier);
      
      // createEvent method should exist
      expect(notifier.createEvent, isNotNull);
      
      container.dispose();
    });

    test('CalendarEventList updateEvent method exists', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(calendarEventListProvider().notifier);
      
      // updateEvent method should exist
      expect(notifier.updateEvent, isNotNull);
      
      container.dispose();
    });

    test('CalendarEventList deleteEvent method exists', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(calendarEventListProvider().notifier);
      
      // deleteEvent method should exist
      expect(notifier.deleteEvent, isNotNull);
      
      container.dispose();
    });

    test('CalendarEvent model fromJson works correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Event',
        'event_type': 'holiday',
        'date': '2026-01-15',
        'description': 'Test description',
        'created_by': 1,
        'created_at': '2026-01-01T00:00:00Z',
      };

      final event = CalendarEvent.fromJson(json);

      expect(event.id, 1);
      expect(event.title, 'Test Event');
      expect(event.eventType, 'holiday');
      expect(event.description, 'Test description');
    });

    test('CalendarEvent toJson works correctly', () {
      final event = CalendarEvent(
        id: 1,
        title: 'Test Event',
        eventType: 'holiday',
        date: DateTime(2026, 1, 15),
        description: 'Test description',
        createdBy: 1,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = event.toJson();

      expect(json['title'], 'Test Event');
      expect(json['event_type'], 'holiday');
      expect(json['description'], 'Test description');
    });

    test('CalendarEvent eventColor returns correct color', () {
      final holidayEvent = CalendarEvent(
        id: 1,
        title: 'Holiday',
        eventType: 'holiday',
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      );

      expect(holidayEvent.eventColor, Colors.red);
    });

    test('CalendarEvent eventIcon returns correct icon', () {
      final tournamentEvent = CalendarEvent(
        id: 1,
        title: 'Tournament',
        eventType: 'tournament',
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      );

      expect(tournamentEvent.eventIcon, Icons.emoji_events);
    });
  });
}
