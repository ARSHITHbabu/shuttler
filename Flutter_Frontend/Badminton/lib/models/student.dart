/// Student data model matching backend schema
class Student {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int? age;
  final String? guardianName;
  final String? guardianPhone;
  final String? address;
  final String? dateOfBirth;
  final String? medicalConditions;
  final String status;
  final String? tShirtSize;
  final String? bloodGroup;
  final String? profilePhoto;
  final String? fcmToken;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.age,
    this.guardianName,
    this.guardianPhone,
    this.address,
    this.dateOfBirth,
    this.medicalConditions,
    required this.status,
    this.tShirtSize,
    this.bloodGroup,
    this.profilePhoto,
    this.fcmToken,
  });

  /// Create Student instance from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      age: json['age'] as int?,
      guardianName: json['guardian_name'] as String?,
      guardianPhone: json['guardian_phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      medicalConditions: json['medical_conditions'] as String?,
      status: json['status'] as String? ?? 'active',
      tShirtSize: json['t_shirt_size'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  /// Convert Student instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'address': address,
      'date_of_birth': dateOfBirth,
      'medical_conditions': medicalConditions,
      'status': status,
      't_shirt_size': tShirtSize,
      'blood_group': bloodGroup,
      'profile_photo': profilePhoto,
      'fcm_token': fcmToken,
    };
  }

  /// Create a copy of Student with updated fields
  Student copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? guardianName,
    String? guardianPhone,
    String? address,
    String? dateOfBirth,
    String? medicalConditions,
    String? status,
    String? tShirtSize,
    String? bloodGroup,
    String? profilePhoto,
    String? fcmToken,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      status: status ?? this.status,
      tShirtSize: tShirtSize ?? this.tShirtSize,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $name, email: $email, phone: $phone, '
        'age: $age, guardianName: $guardianName, guardianPhone: $guardianPhone, '
        'address: $address, dateOfBirth: $dateOfBirth, medicalConditions: $medicalConditions, '
        'status: $status, tShirtSize: $tShirtSize, profilePhoto: $profilePhoto, fcmToken: $fcmToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Student &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.age == age &&
        other.guardianName == guardianName &&
        other.guardianPhone == guardianPhone &&
        other.address == address &&
        other.dateOfBirth == dateOfBirth &&
        other.medicalConditions == medicalConditions &&
        other.status == status &&
        other.tShirtSize == tShirtSize &&
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
      age,
      guardianName,
      guardianPhone,
      address,
      dateOfBirth,
      medicalConditions,
      status,
      tShirtSize,
      bloodGroup,
      profilePhoto,
      fcmToken,
    );
  }
}
