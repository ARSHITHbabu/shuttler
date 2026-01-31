/// Student Registration Request data model matching backend schema
class StudentRegistrationRequest {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String status; // "pending", "approved", "rejected"
  final DateTime submittedAt;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final String? guardianName;
  final String? guardianPhone;
  final String? dateOfBirth;
  final String? address;
  final String? tShirtSize;
  final String? bloodGroup;
  final int? invitationId;
  final int? invitedByCoachId;
  final String? invitedByCoachName;

  StudentRegistrationRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.guardianName,
    this.guardianPhone,
    this.dateOfBirth,
    this.address,
    this.tShirtSize,
    this.bloodGroup,
    this.invitationId,
    this.invitedByCoachId,
    this.invitedByCoachName,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// Create StudentRegistrationRequest instance from JSON
  factory StudentRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return StudentRegistrationRequest(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedBy: json['reviewed_by'] as int?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewNotes: json['review_notes'] as String?,
      guardianName: json['guardian_name'] as String?,
      guardianPhone: json['guardian_phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      address: json['address'] as String?,
      tShirtSize: json['t_shirt_size'] as String?,
      bloodGroup: json['blood_group'] as String?,
      invitationId: json['invitation_id'] as int?,
      invitedByCoachId: json['invited_by_coach_id'] as int?,
      invitedByCoachName: json['invited_by_coach_name'] as String?,
    );
  }

  /// Convert StudentRegistrationRequest instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'review_notes': reviewNotes,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'date_of_birth': dateOfBirth,
      'address': address,
      't_shirt_size': tShirtSize,
      'blood_group': bloodGroup,
      'invitation_id': invitationId,
      'invited_by_coach_id': invitedByCoachId,
      'invited_by_coach_name': invitedByCoachName,
    };
  }
}
