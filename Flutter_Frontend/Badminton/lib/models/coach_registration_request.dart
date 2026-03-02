/// Coach Registration Request data model matching backend schema
class CoachRegistrationRequest {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? specialization;
  final int? experienceYears;
  final String status; // "pending", "approved", "rejected"
  final DateTime submittedAt;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  CoachRegistrationRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.specialization,
    this.experienceYears,
    required this.status,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// Create CoachRegistrationRequest instance from JSON
  factory CoachRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return CoachRegistrationRequest(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      specialization: json['specialization'] as String?,
      experienceYears: json['experience_years'] as int?,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedBy: json['reviewed_by'] as int?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewNotes: json['review_notes'] as String?,
    );
  }

  /// Convert CoachRegistrationRequest instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'experience_years': experienceYears,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'review_notes': reviewNotes,
    };
  }
}
