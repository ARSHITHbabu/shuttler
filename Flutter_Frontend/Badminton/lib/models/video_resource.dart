/// Video resource data model for training videos uploaded for students
class VideoResource {
  final int id;
  final int? studentId; // Keep for backward compatibility
  final String? studentName;
  final String? title;
  final String url;
  final String? remarks;
  final int? uploadedBy;
  final String? uploaderName; // Added uploader name
  final String audienceType; // "all", "batch", "student"
  final List<int> targetIds;
  final DateTime createdAt;

  VideoResource({
    required this.id,
    this.studentId,
    this.studentName,
    this.title,
    required this.url,
    this.remarks,
    this.uploadedBy,
    this.uploaderName,
    required this.audienceType,
    this.targetIds = const [],
    required this.createdAt,
  });

  /// Create VideoResource instance from JSON
  factory VideoResource.fromJson(Map<String, dynamic> json) {
    return VideoResource(
      id: json['id'] as int,
      studentId: json['student_id'] as int?,
      studentName: json['student_name'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String,
      remarks: json['remarks'] as String?,
      uploadedBy: json['uploaded_by'] as int?,
      uploaderName: json['uploader_name'] as String?,
      audienceType: json['audience_type'] as String? ?? 'student',
      targetIds: json['target_ids'] != null
          ? List<int>.from(json['target_ids'] as List)
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert VideoResource instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'batch_id': batchId,
      'session_id': sessionId,
      'student_name': studentName,
      'title': title,
      'url': url,
      'remarks': remarks,
      'uploaded_by': uploadedBy,
      'uploader_name': uploaderName,
      'audience_type': audienceType,
      'target_ids': targetIds,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy of VideoResource with updated fields
  VideoResource copyWith({
    int? id,
    int? studentId,
    int? batchId,
    int? sessionId,
    String? studentName,
    String? title,
    String? url,
    String? remarks,
    int? uploadedBy,
    String? uploaderName,
    String? audienceType,
    List<int>? targetIds,
    DateTime? createdAt,
  }) {
    return VideoResource(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      sessionId: sessionId ?? this.sessionId,
      studentName: studentName ?? this.studentName,
      title: title ?? this.title,
      url: url ?? this.url,
      remarks: remarks ?? this.remarks,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      audienceType: audienceType ?? this.audienceType,
      targetIds: targetIds ?? this.targetIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get formatted date string
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get display title (fallback to "Untitled Video" if null)
  String get displayTitle => title ?? 'Untitled Video';

  @override
  String toString() {
    return 'VideoResource(id: $id, studentId: $studentId, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoResource && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
