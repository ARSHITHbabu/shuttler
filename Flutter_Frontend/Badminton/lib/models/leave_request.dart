/// Leave Request data model matching backend schema
class LeaveRequest {
  final int id;
  final int coachId;
  final String coachName;
  final DateTime startDate;
  final DateTime endDate;
  final String leaveType; // "sick", "personal", "emergency", "other"
  final String reason;
  final String status; // "pending", "approved", "rejected"
  final DateTime submittedAt;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  LeaveRequest({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    required this.status,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  /// Create LeaveRequest instance from JSON
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as int,
      coachId: json['coach_id'] as int,
      coachName: json['coach_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      leaveType: json['leave_type'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedBy: json['reviewed_by'] as int?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewNotes: json['review_notes'] as String?,
    );
  }

  /// Convert LeaveRequest instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coach_id': coachId,
      'coach_name': coachName,
      'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'end_date': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'leave_type': leaveType,
      'reason': reason,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'review_notes': reviewNotes,
    };
  }

  /// Create a copy of LeaveRequest with updated fields
  LeaveRequest copyWith({
    int? id,
    int? coachId,
    String? coachName,
    DateTime? startDate,
    DateTime? endDate,
    String? leaveType,
    String? reason,
    String? status,
    DateTime? submittedAt,
    int? reviewedBy,
    DateTime? reviewedAt,
    String? reviewNotes,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      leaveType: leaveType ?? this.leaveType,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
    );
  }

  String get leaveTypeLabel {
    switch (leaveType.toLowerCase()) {
      case 'sick':
        return 'Sick Leave';
      case 'personal':
        return 'Personal Leave';
      case 'emergency':
        return 'Emergency';
      case 'other':
        return 'Other';
      default:
        return leaveType;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  @override
  String toString() {
    return 'LeaveRequest(id: $id, coachId: $coachId, coachName: $coachName, '
        'startDate: $startDate, endDate: $endDate, leaveType: $leaveType, '
        'reason: $reason, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LeaveRequest &&
        other.id == id &&
        other.coachId == coachId &&
        other.coachName == coachName &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.leaveType == leaveType &&
        other.reason == reason &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      coachId,
      coachName,
      startDate,
      endDate,
      leaveType,
      reason,
      status,
    );
  }
}
