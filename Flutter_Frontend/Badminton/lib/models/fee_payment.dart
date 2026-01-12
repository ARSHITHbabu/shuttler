/// Fee Payment data model
class FeePayment {
  final int id;
  final int feeId;
  final double amount;
  final DateTime paidDate;
  final int? payeeStudentId;
  final String? payeeStudentName;
  final String? paymentMethod;
  final String? collectedBy;
  final DateTime? createdAt;

  FeePayment({
    required this.id,
    required this.feeId,
    required this.amount,
    required this.paidDate,
    this.payeeStudentId,
    this.payeeStudentName,
    this.paymentMethod,
    this.collectedBy,
    this.createdAt,
  });

  /// Create FeePayment instance from JSON
  factory FeePayment.fromJson(Map<String, dynamic> json) {
    return FeePayment(
      id: json['id'] as int,
      feeId: json['fee_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      paidDate: DateTime.parse(json['paid_date'] as String),
      payeeStudentId: json['payee_student_id'] as int?,
      payeeStudentName: json['payee_student_name'] as String?,
      paymentMethod: json['payment_method'] as String?,
      collectedBy: json['collected_by'] as String?,
      createdAt: json['created_at'] != null && json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert FeePayment instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'fee_id': feeId,
      'amount': amount,
      'paid_date': paidDate.toIso8601String().split('T')[0],
      'payee_student_id': payeeStudentId,
      'payment_method': paymentMethod,
      'collected_by': collectedBy,
    };
  }
}
