/// Batch data model matching backend schema
class Batch {
  final int id;
  final String batchName;
  final String timing; // e.g., "6:00 AM - 7:30 AM"
  final String period; // e.g., "Mon, Wed, Fri" or "Daily"
  final int capacity;
  final String fees;
  final String startDate;
  final int? assignedCoachId;
  final String? assignedCoachName;
  final String? location;
  final String createdBy;
  final int? sessionId; // Link to session/season

  Batch({
    required this.id,
    required this.batchName,
    required this.timing,
    required this.period,
    required this.capacity,
    required this.fees,
    required this.startDate,
    this.assignedCoachId,
    this.assignedCoachName,
    this.location,
    required this.createdBy,
    this.sessionId,
  });

  /// Create Batch instance from JSON
  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as int,
      batchName: json['batch_name'] as String,
      timing: json['timing'] as String,
      period: json['period'] as String,
      capacity: json['capacity'] as int,
      fees: json['fees'] as String,
      startDate: json['start_date'] as String,
      assignedCoachId: json['assigned_coach_id'] as int?,
      assignedCoachName: json['assigned_coach_name'] as String?,
      location: json['location'] as String?,
      createdBy: json['created_by'] as String,
      sessionId: json['session_id'] as int?,
    );
  }

  /// Convert Batch instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'batch_name': batchName,
      'timing': timing,
      'period': period,
      'capacity': capacity,
      'fees': fees,
      'start_date': startDate,
      'assigned_coach_id': assignedCoachId,
      'assigned_coach_name': assignedCoachName,
      'location': location,
      'created_by': createdBy,
      'session_id': sessionId,
    };
  }

  /// Create a copy of Batch with updated fields
  Batch copyWith({
    int? id,
    String? batchName,
    String? timing,
    String? period,
    int? capacity,
    String? fees,
    String? startDate,
    int? assignedCoachId,
    String? assignedCoachName,
    String? location,
    String? createdBy,
    int? sessionId,
  }) {
    return Batch(
      id: id ?? this.id,
      batchName: batchName ?? this.batchName,
      timing: timing ?? this.timing,
      period: period ?? this.period,
      capacity: capacity ?? this.capacity,
      fees: fees ?? this.fees,
      startDate: startDate ?? this.startDate,
      assignedCoachId: assignedCoachId ?? this.assignedCoachId,
      assignedCoachName: assignedCoachName ?? this.assignedCoachName,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  /// Get formatted time range (alias for timing)
  String get timeRange => timing;

  /// Get formatted days string (alias for period)
  String get daysString => period;

  /// Get name (alias for batchName for compatibility)
  String get name => batchName;

  /// Get coachId (alias for assignedCoachId)
  int? get coachId => assignedCoachId;

  /// Get coachName (alias for assignedCoachName)
  String? get coachName => assignedCoachName;

  /// Get days list (parse from period)
  List<String> get days => period.split(',').map((d) => d.trim()).toList();

  @override
  String toString() {
    return 'Batch(id: $id, name: $batchName, timing: $timing, period: $period, capacity: $capacity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Batch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
