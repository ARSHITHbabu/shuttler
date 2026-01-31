/// Notification data model matching backend schema
class Notification {
  final int id;
  final int userId;
  final String userType; // 'student', 'coach', 'owner'
  final String title;
  final String body;
  final String type; // 'fee_due', 'attendance', 'announcement', 'general'
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // Extra metadata

  Notification({
    required this.id,
    required this.userId,
    required this.userType,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  /// Create Notification instance from JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userType: json['user_type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String? ?? 'general',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Convert Notification instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_type': userType,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
    };
  }

  /// Create a copy of Notification with updated fields
  Notification copyWith({
    int? id,
    int? userId,
    String? userType,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, userId: $userId, type: $type, isRead: $isRead, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
