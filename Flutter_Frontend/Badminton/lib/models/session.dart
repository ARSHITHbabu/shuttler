/// Session/Season data model matching backend schema
/// Sessions group multiple batches together (e.g., Fall 2026, Winter 2026)
class Session {
  final int id;
  final String name; // e.g., "Fall 2026", "Winter 2026"
  final DateTime startDate;
  final DateTime endDate;
  final String status; // "active" or "archived"
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Session({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Session instance from JSON
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as int,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Session instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'status': status,
    };
  }

  /// Create a copy of Session with updated fields
  Session copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if session is active
  bool get isActive => status == 'active';

  /// Check if session is archived
  bool get isArchived => status == 'archived';

  /// Check if session is currently ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if session is upcoming
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  /// Check if session is past
  bool get isPast => DateTime.now().isAfter(endDate);

  @override
  String toString() {
    return 'Session(id: $id, name: $name, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
