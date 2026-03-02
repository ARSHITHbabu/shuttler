import 'package:flutter/material.dart';

/// Announcement data model matching backend schema
class Announcement {
  final int id;
  final String title;
  final String message;
  final String targetAudience; // 'all', 'students', 'coaches'
  final String priority; // 'General', 'Important'
  final int? createdBy; // coach_id (owner)
  final String? createdByName;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isSent;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.targetAudience,
    required this.priority,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    this.scheduledAt,
    required this.isSent,
  });

  /// Create Announcement instance from JSON
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      targetAudience: json['target_audience'] as String? ?? 'all',
      priority: json['priority'] as String? ?? 'General',
      createdBy: json['created_by'] as int?,
      createdByName: json['created_by_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      isSent: json['is_sent'] as bool? ?? false,
    );
  }

  /// Convert Announcement instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'target_audience': targetAudience,
      'priority': priority,
      'created_by': createdBy,
      'scheduled_at': scheduledAt?.toIso8601String(),
    };
  }

  /// Create a copy of Announcement with updated fields
  Announcement copyWith({
    int? id,
    String? title,
    String? message,
    String? targetAudience,
    String? priority,
    int? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isSent,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      targetAudience: targetAudience ?? this.targetAudience,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isSent: isSent ?? this.isSent,
    );
  }

  /// Get priority color
  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'important':
        return const Color(0xFFFF9800); // Orange
      case 'general':
      default:
        return const Color(0xFF4CAF50); // Green
    }
  }

  @override
  String toString() {
    return 'Announcement(id: $id, title: $title, target: $targetAudience, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Announcement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
