/// Coach info for batch assignment
class CoachInfo {
  final int id;
  final String name;

  CoachInfo({
    required this.id,
    required this.name,
  });

  factory CoachInfo.fromJson(Map<String, dynamic> json) {
    return CoachInfo(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Batch data model matching backend schema
class Batch {
  final int id;
  final String batchName;
  final String timing; // e.g., "6:00 AM - 7:30 AM"
  final String period; // e.g., "Mon, Wed, Fri" or "Daily"
  final int capacity;
  final String fees;
  final String startDate;
  final int? assignedCoachId; // Deprecated: kept for backward compatibility
  final String? assignedCoachName; // Deprecated: kept for backward compatibility
  final List<int> assignedCoachIds; // New: list of coach IDs
  final List<CoachInfo> assignedCoaches; // New: list of coach info
  final String? location;
  final String createdBy;
  final int? sessionId; // Link to session/season
  final String status;
  final String? inactiveAt;

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
    List<int>? assignedCoachIds,
    List<CoachInfo>? assignedCoaches,
    this.location,
    required this.createdBy,
    this.sessionId,
    this.status = 'active',
    this.inactiveAt,
  })  : assignedCoachIds = assignedCoachIds ?? [],
        assignedCoaches = assignedCoaches ?? [];

  /// Create Batch instance from JSON
  factory Batch.fromJson(Map<String, dynamic> json) {
    // Handle multiple coaches (new format)
    List<int> coachIds = [];
    List<CoachInfo> coaches = [];
    
    if (json['assigned_coach_ids'] != null) {
      coachIds = (json['assigned_coach_ids'] as List)
          .map((id) => id as int)
          .toList();
    }
    
    if (json['assigned_coaches'] != null) {
      coaches = (json['assigned_coaches'] as List)
          .map((coach) => CoachInfo.fromJson(coach as Map<String, dynamic>))
          .toList();
    }
    
    // Backward compatibility: if no new format, use old single coach
    if (coachIds.isEmpty && json['assigned_coach_id'] != null) {
      coachIds = [json['assigned_coach_id'] as int];
    }
    
    return Batch(
      id: json['id'] as int,
      batchName: json['batch_name'] as String,
      timing: json['timing'] as String,
      period: json['period'] as String,
      capacity: json['capacity'] as int,
      fees: json['fees'] as String,
      startDate: json['start_date'] as String,
      assignedCoachId: json['assigned_coach_id'] as int?, // Backward compatibility
      assignedCoachName: json['assigned_coach_name'] as String?, // Backward compatibility
      assignedCoachIds: coachIds,
      assignedCoaches: coaches,
      location: json['location'] as String?,
      createdBy: json['created_by'] as String,
      sessionId: json['session_id'] as int?,
      status: json['status'] as String? ?? 'active',
      inactiveAt: json['inactive_at'] as String?,
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
      'assigned_coach_id': assignedCoachId, // Backward compatibility
      'assigned_coach_name': assignedCoachName, // Backward compatibility
      'assigned_coach_ids': assignedCoachIds,
      'assigned_coaches': assignedCoaches.map((c) => c.toJson()).toList(),
      'location': location,
      'created_by': createdBy,
      'session_id': sessionId,
      'status': status,
      'inactive_at': inactiveAt,
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
    List<int>? assignedCoachIds,
    List<CoachInfo>? assignedCoaches,
    String? location,
    String? createdBy,
    int? sessionId,
    String? status,
    String? inactiveAt,
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
      assignedCoachIds: assignedCoachIds ?? this.assignedCoachIds,
      assignedCoaches: assignedCoaches ?? this.assignedCoaches,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      inactiveAt: inactiveAt ?? this.inactiveAt,
    );
  }

  /// Get formatted time range (alias for timing)
  String get timeRange => timing;

  /// Get formatted days string (alias for period)
  String get daysString => period;

  /// Get name (alias for batchName for compatibility)
  String get name => batchName;

  /// Get coachId (alias for assignedCoachId - backward compatibility)
  int? get coachId => assignedCoachIds.isNotEmpty ? assignedCoachIds.first : assignedCoachId;

  /// Get coachName (alias for assignedCoachName - backward compatibility)
  String? get coachName => assignedCoaches.isNotEmpty 
      ? assignedCoaches.first.name 
      : assignedCoachName;
  
  /// Get all coach names as comma-separated string
  String get coachNamesString => assignedCoaches.isNotEmpty
      ? assignedCoaches.map((c) => c.name).join(', ')
      : (assignedCoachName ?? '');

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
