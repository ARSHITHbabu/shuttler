/// BMI Record data model matching backend schema
class BMIRecord {
  final int id;
  final int studentId;
  final String? studentName;
  final DateTime date;
  final double height; // in cm
  final double weight; // in kg
  final double bmi;
  final String? healthStatus; // 'underweight', 'normal', 'overweight', 'obese'
  final DateTime? createdAt;

  BMIRecord({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.date,
    required this.height,
    required this.weight,
    required this.bmi,
    this.healthStatus,
    this.createdAt,
  });

  /// Create BMIRecord instance from JSON
  factory BMIRecord.fromJson(Map<String, dynamic> json) {
    return BMIRecord(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String?,
      date: DateTime.parse(json['date'] as String),
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      healthStatus: json['health_status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert BMIRecord instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'health_status': healthStatus,
    };
  }

  /// Create a copy of BMIRecord with updated fields
  BMIRecord copyWith({
    int? id,
    int? studentId,
    String? studentName,
    DateTime? date,
    double? height,
    double? weight,
    double? bmi,
    String? healthStatus,
    DateTime? createdAt,
  }) {
    return BMIRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      healthStatus: healthStatus ?? this.healthStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate BMI from height and weight
  static double calculateBMI(double heightCm, double weightKg) {
    // BMI = weight (kg) / (height (m))^2
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  /// Get health status based on BMI
  static String getHealthStatus(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

  @override
  String toString() {
    return 'BMIRecord(id: $id, studentId: $studentId, date: $date, bmi: ${bmi.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BMIRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
