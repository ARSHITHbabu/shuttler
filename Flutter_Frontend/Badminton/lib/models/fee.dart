import 'fee_payment.dart';

/// Fee data model matching backend schema
class Fee {
  final int id;
  final int studentId;
  final String? studentName;
  final int batchId;
  final String? batchName;
  final double amount;
  final double totalPaid;
  final double pendingAmount;
  final DateTime dueDate;
  final String status; // 'paid', 'pending', 'overdue'
  final int? payeeStudentId;
  final String? payeeStudentName;
  final List<FeePayment>? payments;
  final DateTime? createdAt;

  Fee({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.batchId,
    this.batchName,
    required this.amount,
    required this.totalPaid,
    required this.pendingAmount,
    required this.dueDate,
    required this.status,
    this.payeeStudentId,
    this.payeeStudentName,
    this.payments,
    this.createdAt,
  });

  /// Create Fee instance from JSON
  factory Fee.fromJson(Map<String, dynamic> json) {
    List<FeePayment>? payments;
    if (json['payments'] != null && json['payments'] is List) {
      payments = (json['payments'] as List)
          .map((p) => FeePayment.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    
    return Fee(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String?,
      batchId: json['batch_id'] as int,
      batchName: json['batch_name'] as String?,
      amount: (json['amount'] as num).toDouble(),
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String,
      payeeStudentId: json['payee_student_id'] as int?,
      payeeStudentName: json['payee_student_name'] as String?,
      payments: payments,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert Fee instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'batch_id': batchId,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'payee_student_id': payeeStudentId,
    };
  }

  /// Create a copy of Fee with updated fields
  Fee copyWith({
    int? id,
    int? studentId,
    String? studentName,
    int? batchId,
    String? batchName,
    double? amount,
    double? totalPaid,
    double? pendingAmount,
    DateTime? dueDate,
    String? status,
    int? payeeStudentId,
    String? payeeStudentName,
    List<FeePayment>? payments,
    DateTime? createdAt,
  }) {
    return Fee(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      amount: amount ?? this.amount,
      totalPaid: totalPaid ?? this.totalPaid,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      payeeStudentId: payeeStudentId ?? this.payeeStudentId,
      payeeStudentName: payeeStudentName ?? this.payeeStudentName,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if fee is overdue (7 days after due date)
  bool get isOverdue {
    if (status == 'paid') return false;
    final daysOverdue = DateTime.now().difference(dueDate).inDays;
    return daysOverdue >= 7;
  }

  @override
  String toString() {
    return 'Fee(id: $id, studentId: $studentId, amount: $amount, totalPaid: $totalPaid, pendingAmount: $pendingAmount, status: $status, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
