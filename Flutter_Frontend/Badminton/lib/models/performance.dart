/// Performance data model matching backend schema
class Performance {
  final int id;
  final int studentId;
  final String? studentName;
  final DateTime date;
  final int serve; // 1-5 rating
  final int smash; // 1-5 rating
  final int footwork; // 1-5 rating
  final int defense; // 1-5 rating
  final int stamina; // 1-5 rating
  final String? comments;
  final DateTime? createdAt;

  Performance({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.date,
    required this.serve,
    required this.smash,
    required this.footwork,
    required this.defense,
    required this.stamina,
    this.comments,
    this.createdAt,
  });

  /// Create Performance instance from JSON
  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String?,
      date: DateTime.parse(json['date'] as String),
      serve: json['serve'] as int,
      smash: json['smash'] as int,
      footwork: json['footwork'] as int,
      defense: json['defense'] as int,
      stamina: json['stamina'] as int,
      comments: json['comments'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert Performance instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'serve': serve,
      'smash': smash,
      'footwork': footwork,
      'defense': defense,
      'stamina': stamina,
      'comments': comments,
    };
  }

  /// Create a copy of Performance with updated fields
  Performance copyWith({
    int? id,
    int? studentId,
    String? studentName,
    DateTime? date,
    int? serve,
    int? smash,
    int? footwork,
    int? defense,
    int? stamina,
    String? comments,
    DateTime? createdAt,
  }) {
    return Performance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      serve: serve ?? this.serve,
      smash: smash ?? this.smash,
      footwork: footwork ?? this.footwork,
      defense: defense ?? this.defense,
      stamina: stamina ?? this.stamina,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate average rating
  double get averageRating {
    return (serve + smash + footwork + defense + stamina) / 5.0;
  }

  @override
  String toString() {
    return 'Performance(id: $id, studentId: $studentId, date: $date, avgRating: ${averageRating.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Performance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
