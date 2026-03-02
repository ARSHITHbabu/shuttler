class CoachSalary {
  final int id;
  final int coachId;
  final String? coachName;
  final double amount;
  final DateTime paymentDate;
  final String month;
  final String? remarks;

  CoachSalary({
    required this.id,
    required this.coachId,
    this.coachName,
    required this.amount,
    required this.paymentDate,
    required this.month,
    this.remarks,
  });

  factory CoachSalary.fromJson(Map<String, dynamic> json) {
    return CoachSalary(
      id: json['id'],
      coachId: json['coach_id'],
      coachName: json['coach_name'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      month: json['month'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coach_id': coachId,
      'coach_name': coachName,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'month': month,
      'remarks': remarks,
    };
  }
}
