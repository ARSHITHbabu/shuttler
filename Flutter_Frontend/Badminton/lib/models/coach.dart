class Coach {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? specialization;
  final int? experienceYears;
  final String status;
  final double? monthlySalary;
  final DateTime? joiningDate;
  final String? profilePhoto;
  final String? fcmToken;

  Coach({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.specialization,
    this.experienceYears,
    required this.status,
    this.monthlySalary,
    this.joiningDate,
    this.profilePhoto,
    this.fcmToken,
  });

  /// Create Coach instance from JSON
  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      specialization: json['specialization'] as String?,
      experienceYears: json['experience_years'] as int?,
      status: json['status'] as String? ?? 'active',
      monthlySalary: json['monthly_salary'] != null ? (json['monthly_salary'] as num).toDouble() : null,
      joiningDate: json['joining_date'] != null ? DateTime.parse(json['joining_date']) : null,
      profilePhoto: json['profile_photo'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  /// Convert Coach instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'experience_years': experienceYears,
      'status': status,
      'monthly_salary': monthlySalary,
      'joining_date': joiningDate?.toIso8601String().split('T')[0],
      'profile_photo': profilePhoto,
      'fcm_token': fcmToken,
    };
  }

  /// Create a copy of Coach with updated fields
  Coach copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? specialization,
    int? experienceYears,
    String? status,
    double? monthlySalary,
    DateTime? joiningDate,
    String? profilePhoto,
    String? fcmToken,
  }) {
    return Coach(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      status: status ?? this.status,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      joiningDate: joiningDate ?? this.joiningDate,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'Coach(id: $id, name: $name, email: $email, phone: $phone, '
        'specialization: $specialization, experienceYears: $experienceYears, '
        'status: $status, monthlySalary: $monthlySalary, joiningDate: $joiningDate, '
        'profilePhoto: $profilePhoto, fcmToken: $fcmToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coach &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.specialization == specialization &&
        other.experienceYears == experienceYears &&
        other.status == status &&
        other.monthlySalary == monthlySalary &&
        other.joiningDate == joiningDate &&
        other.profilePhoto == profilePhoto &&
        other.fcmToken == fcmToken;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      phone,
      specialization,
      experienceYears,
      status,
      monthlySalary,
      joiningDate,
      profilePhoto,
      fcmToken,
    );
  }
}
