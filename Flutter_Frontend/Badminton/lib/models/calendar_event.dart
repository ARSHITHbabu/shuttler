import 'package:flutter/material.dart';

/// Calendar Event data model matching backend schema
class CalendarEvent {
  final int id;
  final String title;
  final String eventType; // 'holiday', 'tournament', 'event', 'leave'
  final DateTime date;
  final DateTime? endDate; // For date ranges (e.g., multi-day leave)
  final String? description;
  final int? createdBy;
  final String creatorType; // 'coach' or 'owner'
  final int? relatedLeaveRequestId; // Link to leave request if this is a leave event
  final int? relatedTournamentId; // Link to tournament
  final int? relatedAnnouncementId; // Link to announcement
  final int? relatedScheduleId; // Link to schedule
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.date,
    this.endDate,
    this.description,
    this.createdBy,
    this.creatorType = 'coach',
    this.relatedLeaveRequestId,
    this.relatedTournamentId,
    this.relatedAnnouncementId,
    this.relatedScheduleId,
    required this.createdAt,
  });

  /// Create CalendarEvent instance from JSON
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as int,
      title: json['title'] as String,
      eventType: json['event_type'] as String,
      date: DateTime.parse(json['date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      description: json['description'] as String?,
      createdBy: json['created_by'] as int?,
      creatorType: json['creator_type'] as String? ?? 'coach',
      relatedLeaveRequestId: json['related_leave_request_id'] as int?,
      relatedTournamentId: json['related_tournament_id'] as int?,
      relatedAnnouncementId: json['related_announcement_id'] as int?,
      relatedScheduleId: json['related_schedule_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert CalendarEvent instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'event_type': eventType,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'end_date': endDate?.toIso8601String().split('T')[0],
      'description': description,
      'created_by': createdBy,
      'creator_type': creatorType,
      'related_leave_request_id': relatedLeaveRequestId,
      'related_tournament_id': relatedTournamentId,
      'related_announcement_id': relatedAnnouncementId,
      'related_schedule_id': relatedScheduleId,
    };
  }

  /// Create a copy of CalendarEvent with updated fields
  CalendarEvent copyWith({
    int? id,
    String? title,
    String? eventType,
    DateTime? date,
    DateTime? endDate,
    String? description,
    int? createdBy,
    String? creatorType,
    int? relatedLeaveRequestId,
    int? relatedTournamentId,
    int? relatedAnnouncementId,
    int? relatedScheduleId,
    DateTime? createdAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      eventType: eventType ?? this.eventType,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      creatorType: creatorType ?? this.creatorType,
      relatedLeaveRequestId: relatedLeaveRequestId ?? this.relatedLeaveRequestId,
      relatedTournamentId: relatedTournamentId ?? this.relatedTournamentId,
      relatedAnnouncementId: relatedAnnouncementId ?? this.relatedAnnouncementId,
      relatedScheduleId: relatedScheduleId ?? this.relatedScheduleId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get event color based on type
  /// Holidays are red, leave events are orange/amber, all other events (tournament, event) are jade green
  Color get eventColor {
    switch (eventType.toLowerCase()) {
      case 'holiday':
        return Colors.red;
      case 'leave':
        return const Color(0xFFFF9800); // Orange/Amber
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

  /// Check if this is a leave event
  bool get isLeave => eventType.toLowerCase() == 'leave';

  /// Check if this event spans multiple days
  bool get isMultiDay => endDate != null && endDate!.difference(date).inDays > 0;

  /// Get event icon based on type
  IconData get eventIcon {
    switch (eventType.toLowerCase()) {
      case 'holiday':
        return Icons.celebration;
      case 'leave':
        return Icons.airplane_ticket;
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
