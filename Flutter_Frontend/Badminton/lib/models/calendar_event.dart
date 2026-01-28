import 'package:flutter/material.dart';

/// Calendar Event data model matching backend schema
class CalendarEvent {
  final int id;
  final String title;
  final String eventType; // 'holiday', 'tournament', 'event'
  final DateTime date;
  final String? description;
  final int? createdBy;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.date,
    this.description,
    this.createdBy,
    required this.createdAt,
  });

  /// Create CalendarEvent instance from JSON
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as int,
      title: json['title'] as String,
      eventType: json['event_type'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      createdBy: json['created_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert CalendarEvent instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'event_type': eventType,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'description': description,
      'created_by': createdBy,
    };
  }

  /// Create a copy of CalendarEvent with updated fields
  CalendarEvent copyWith({
    int? id,
    String? title,
    String? eventType,
    DateTime? date,
    String? description,
    int? createdBy,
    DateTime? createdAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      eventType: eventType ?? this.eventType,
      date: date ?? this.date,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get event color based on type
  /// Holidays are red, all other events (tournament, event) are jade green
  Color get eventColor {
    switch (eventType.toLowerCase()) {
      case 'holiday':
        return Colors.red;
      case 'tournament':
        return const Color(0xFF00A86B); // Jade green
      case 'event':
        return const Color(0xFF00A86B); // Jade green
      default:
        return const Color(0xFF00A86B); // Jade green
    }
  }

  /// Check if this is a holiday event
  bool get isHoliday => eventType.toLowerCase() == 'holiday';

  /// Get event icon based on type
  IconData get eventIcon {
    switch (eventType.toLowerCase()) {
      case 'holiday':
        return Icons.beach_access;
      case 'tournament':
        return Icons.emoji_events;
      case 'event':
        return Icons.event;
      default:
        return Icons.calendar_today;
    }
  }

  @override
  String toString() {
    return 'CalendarEvent(id: $id, title: $title, type: $eventType, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
