/// Performance data model matching backend schema
class Performance {
  final int id;
  final int studentId;
  final String? studentName;
  final int batchId;
  final String? batchName;
  final DateTime date;
  final Map<String, int> skills; // specific skills mapping
  final String? comments;
  final DateTime? createdAt;

  Performance({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.batchId,
    this.batchName,
    required this.date,
    required this.skills,
    this.comments,
    this.createdAt,
  });

  /// Create Performance instance from JSON
  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String?,
      batchId: json['batch_id'] as int? ?? 0,
      batchName: json['batch_name'] as String?,
      date: DateTime.parse(json['date'] as String),
      skills: () {
        final raw = json['skills'] as Map<String, dynamic>?;
        if (raw != null && raw.isNotEmpty) {
          return raw.map((key, value) => MapEntry(key, (value as num).toInt()));
        }
        // Fallback: reconstruct from flat fields (legacy backend response)
        final flat = <String, int>{};
        void addFlat(String key) {
          final v = json[key];
          if (v != null && (v as num).toInt() > 0) flat[key] = v.toInt();
        }
        addFlat('serve'); addFlat('smash'); addFlat('footwork');
        addFlat('defense'); addFlat('stamina');
        return flat;
      }(),
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
      'batch_id': batchId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'skills': skills,
      'comments': comments,
    };
  }

  /// Create a copy of Performance with updated fields
  Performance copyWith({
    int? id,
    int? studentId,
    String? studentName,
    int? batchId,
    String? batchName,
    DateTime? date,
    Map<String, int>? skills,
    String? comments,
    DateTime? createdAt,
  }) {
    return Performance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      date: date ?? this.date,
      skills: skills ?? this.skills,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate average rating
  
  // Fallbacks for backward compatibility
  int get serve => skills['serve'] ?? skills['Serve'] ?? 0;
  int get smash => skills['smash'] ?? skills['Smash'] ?? 0;
  int get footwork => skills['footwork'] ?? skills['Footwork'] ?? 0;
  int get defense => skills['defense'] ?? skills['Defense'] ?? 0;
  int get stamina => skills['stamina'] ?? skills['Stamina'] ?? 0;

  double get averageRating {
    if (skills.isEmpty) return 0.0;
    final total = skills.values.fold<int>(0, (sum, val) => sum + val);
    return total / skills.length.toDouble();
  }

  @override
  String toString() {
    return 'Performance(id: $id, studentId: $studentId, batchId: $batchId, date: $date, avgRating: ${averageRating.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Performance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
