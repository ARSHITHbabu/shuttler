/// Fee data model matching backend schema
class Fee {
  final int id;
  final int studentId;
  final String? studentName;
  final double amount;
  final DateTime dueDate;
  final String status; // 'paid', 'pending', 'overdue'
  final DateTime? paidDate;
  final String? paymentMethod; // 'cash', 'online', 'cheque'
  final String? remarks;
  final DateTime? createdAt;

  Fee({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.paymentMethod,
    this.remarks,
    this.createdAt,
  });

  /// Create Fee instance from JSON
  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String?,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String,
      paidDate: json['paid_date'] != null
          ? DateTime.parse(json['paid_date'] as String)
          : null,
      paymentMethod: json['payment_method'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert Fee instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'status': status,
      'paid_date': paidDate?.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'remarks': remarks,
    };
  }

  /// Create a copy of Fee with updated fields
  Fee copyWith({
    int? id,
    int? studentId,
    String? studentName,
    double? amount,
    DateTime? dueDate,
    String? status,
    DateTime? paidDate,
    String? paymentMethod,
    String? remarks,
    DateTime? createdAt,
  }) {
    return Fee(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if fee is overdue
  bool get isOverdue {
    if (status == 'paid') return false;
    return DateTime.now().isAfter(dueDate);
  }

  @override
  String toString() {
    return 'Fee(id: $id, studentId: $studentId, amount: $amount, status: $status, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
