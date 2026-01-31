class Owner {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? specialization;
  final int? experienceYears;
  final String status;
  final String? profilePhoto;
  final String? fcmToken;
  final String? academyName;
  final String? academyAddress;
  final String? academyContact;
  final String? academyEmail;

  Owner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.specialization,
    this.experienceYears,
    required this.status,
    this.profilePhoto,
    this.fcmToken,
    this.academyName,
    this.academyAddress,
    this.academyContact,
    this.academyEmail,
  });

  /// Create Owner instance from JSON
  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      specialization: json['specialization'] as String?,
      experienceYears: json['experience_years'] as int?,
      status: json['status'] as String? ?? 'active',
      profilePhoto: json['profile_photo'] as String?,
      fcmToken: json['fcm_token'] as String?,
      academyName: json['academy_name'] as String?,
      academyAddress: json['academy_address'] as String?,
      academyContact: json['academy_contact'] as String?,
      academyEmail: json['academy_email'] as String?,
    );
  }

  /// Convert Owner instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'experience_years': experienceYears,
      'status': status,
      'profile_photo': profilePhoto,
      'fcm_token': fcmToken,
      'academy_name': academyName,
      'academy_address': academyAddress,
      'academy_contact': academyContact,
      'academy_email': academyEmail,
    };
  }

  /// Create a copy of Owner with updated fields
  Owner copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? specialization,
    int? experienceYears,
    String? status,
    String? profilePhoto,
    String? fcmToken,
    String? academyName,
    String? academyAddress,
    String? academyContact,
    String? academyEmail,
  }) {
    return Owner(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      status: status ?? this.status,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      fcmToken: fcmToken ?? this.fcmToken,
      academyName: academyName ?? this.academyName,
      academyAddress: academyAddress ?? this.academyAddress,
      academyContact: academyContact ?? this.academyContact,
      academyEmail: academyEmail ?? this.academyEmail,
    );
  }

  @override
  String toString() {
    return 'Owner(id: $id, name: $name, email: $email, phone: $phone, '
        'specialization: $specialization, experienceYears: $experienceYears, '
        'status: $status, profilePhoto: $profilePhoto, fcmToken: $fcmToken, '
        'academyName: $academyName, academyAddress: $academyAddress, '
        'academyContact: $academyContact, academyEmail: $academyEmail)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Owner &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.specialization == specialization &&
        other.experienceYears == experienceYears &&
        other.status == status &&
        other.profilePhoto == profilePhoto &&
        other.fcmToken == fcmToken &&
        other.academyName == academyName &&
        other.academyAddress == academyAddress &&
        other.academyContact == academyContact &&
        other.academyEmail == academyEmail;
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
      profilePhoto,
      fcmToken,
      academyName,
      academyAddress,
      academyContact,
      academyEmail,
    );
  }
}
