/// Attendance data model matching backend schema
class Attendance {
  final int id;
  final int studentId;
  final String? studentName;
  final int batchId;
  final String? batchName;
  final DateTime date;
  final String status; // 'present', 'absent'
  final String? remarks;
  final String? markedBy;
  final DateTime? createdAt;

  Attendance({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.batchId,
    this.batchName,
    required this.date,
    required this.status,
    this.remarks,
    this.markedBy,
    this.createdAt,
  });

  /// Create Attendance instance from JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String?,
      batchId: json['batch_id'] as int,
      batchName: json['batch_name'] as String?,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      markedBy: json['marked_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert Attendance instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'batch_id': batchId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'status': status,
      'remarks': remarks,
      'marked_by': markedBy,
    };
  }

  /// Create a copy of Attendance with updated fields
  Attendance copyWith({
    int? id,
    int? studentId,
    String? studentName,
    int? batchId,
    String? batchName,
    DateTime? date,
    String? status,
    String? remarks,
    String? markedBy,
    DateTime? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      markedBy: markedBy ?? this.markedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Attendance(id: $id, studentId: $studentId, batchId: $batchId, date: $date, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Coach Attendance data model
class CoachAttendance {
  final int id;
  final int coachId;
  final String? coachName;
  final DateTime date;
  final String status; // 'present', 'absent'
  final String? remarks;
  final String? markedBy;
  final DateTime? createdAt;

  CoachAttendance({
    required this.id,
    required this.coachId,
    this.coachName,
    required this.date,
    required this.status,
    this.remarks,
    this.markedBy,
    this.createdAt,
  });

  /// Create CoachAttendance instance from JSON
  factory CoachAttendance.fromJson(Map<String, dynamic> json) {
    return CoachAttendance(
      id: json['id'] as int,
      coachId: json['coach_id'] as int,
      coachName: json['coach_name'] as String?,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      markedBy: json['marked_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert CoachAttendance instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'coach_id': coachId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'status': status,
      'remarks': remarks,
      'marked_by': markedBy,
    };
  }

  /// Create a copy of CoachAttendance with updated fields
  CoachAttendance copyWith({
    int? id,
    int? coachId,
    String? coachName,
    DateTime? date,
    String? status,
    String? remarks,
    String? markedBy,
    DateTime? createdAt,
  }) {
    return CoachAttendance(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      markedBy: markedBy ?? this.markedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CoachAttendance(id: $id, coachId: $coachId, date: $date, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoachAttendance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
