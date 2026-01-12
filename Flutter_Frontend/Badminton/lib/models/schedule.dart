/// Schedule (Session) data model matching backend schema
class Schedule {
  final int id;
  final String sessionType; // 'practice', 'tournament', 'camp'
  final String title;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final int? duration; // in minutes
  final int? batchId;
  final String? batchName;
  final List<int>? studentIds;
  final String? location;
  final int? coachId;
  final String? coachName;
  final String? description;
  final DateTime? createdAt;

  Schedule({
    required this.id,
    required this.sessionType,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    this.duration,
    this.batchId,
    this.batchName,
    this.studentIds,
    this.location,
    this.coachId,
    this.coachName,
    this.description,
    this.createdAt,
  });

  /// Create Schedule instance from JSON
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      sessionType: json['session_type'] as String? ?? json['type'] as String? ?? 'practice',
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      duration: json['duration'] as int?,
      batchId: json['batch_id'] as int?,
      batchName: json['batch_name'] as String?,
      studentIds: json['student_ids'] != null
          ? (json['student_ids'] as List).map((e) => e as int).toList()
          : null,
      location: json['location'] as String?,
      coachId: json['coach_id'] as int?,
      coachName: json['coach_name'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert Schedule instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'session_type': sessionType,
      'title': title,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'batch_id': batchId,
      'student_ids': studentIds,
      'location': location,
      'coach_id': coachId,
      'description': description,
    };
  }

  /// Create a copy of Schedule with updated fields
  Schedule copyWith({
    int? id,
    String? sessionType,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? duration,
    int? batchId,
    String? batchName,
    List<int>? studentIds,
    String? location,
    int? coachId,
    String? coachName,
    String? description,
    DateTime? createdAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      sessionType: sessionType ?? this.sessionType,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      studentIds: studentIds ?? this.studentIds,
      location: location ?? this.location,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if session is in the past
  bool get isPast {
    final now = DateTime.now();
    final sessionDateTime = DateTime(date.year, date.month, date.day);
    return sessionDateTime.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Check if session is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  String toString() {
    return 'Schedule(id: $id, type: $sessionType, title: $title, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
