/// Request data model matching backend schema
class Request {
  final int id;
  final String requestType;
  final String requesterType;
  final int requesterId;
  final String status;
  final String title;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? responseMessage;
  final int? respondedBy;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Request({
    required this.id,
    required this.requestType,
    required this.requesterType,
    required this.requesterId,
    required this.status,
    required this.title,
    this.description,
    this.metadata,
    this.responseMessage,
    this.respondedBy,
    this.respondedAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create Request instance from JSON
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'] as int,
      requestType: json['request_type'] as String,
      requesterType: json['requester_type'] as String,
      requesterId: json['requester_id'] as int,
      status: json['status'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      responseMessage: json['response_message'] as String?,
      respondedBy: json['responded_by'] as int?,
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Request instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_type': requestType,
      'requester_type': requesterType,
      'requester_id': requesterId,
      'status': status,
      'title': title,
      'description': description,
      'metadata': metadata,
      'response_message': responseMessage,
      'responded_by': respondedBy,
      'responded_at': respondedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy of Request with updated fields
  Request copyWith({
    int? id,
    String? requestType,
    String? requesterType,
    int? requesterId,
    String? status,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
    String? responseMessage,
    int? respondedBy,
    DateTime? respondedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Request(
      id: id ?? this.id,
      requestType: requestType ?? this.requestType,
      requesterType: requesterType ?? this.requesterType,
      requesterId: requesterId ?? this.requesterId,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      responseMessage: responseMessage ?? this.responseMessage,
      respondedBy: respondedBy ?? this.respondedBy,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display icon based on request type
  String getDisplayIcon() {
    switch (requestType) {
      case 'student_registration':
        return 'person_add';
      case 'coach_leave':
        return 'event_busy';
      case 'batch_enrollment':
        return 'group_add';
      case 'fee_extension':
        return 'schedule';
      default:
        return 'description';
    }
  }

  /// Get display color based on status
  String getStatusColor() {
    switch (status) {
      case 'pending':
        return 'orange';
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      case 'cancelled':
        return 'grey';
      default:
        return 'blue';
    }
  }

  /// Check if request is pending
  bool get isPending => status == 'pending';

  /// Check if request is approved
  bool get isApproved => status == 'approved';

  /// Check if request is rejected
  bool get isRejected => status == 'rejected';
}
