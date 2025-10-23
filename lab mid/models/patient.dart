class Patient {
  int? id;
  String name;
  int age;
  String gender;
  String phone;
  String email;
  String address;
  String bloodGroup;
  String medicalHistory;
  String? profileImagePath;
  String? documentPath;
  DateTime createdAt;
  DateTime updatedAt;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.address,
    required this.bloodGroup,
    required this.medicalHistory,
    this.profileImagePath,
    this.documentPath,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Patient to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'bloodGroup': bloodGroup,
      'medicalHistory': medicalHistory,
      'profileImagePath': profileImagePath,
      'documentPath': documentPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Patient from Map
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      bloodGroup: map['bloodGroup'],
      medicalHistory: map['medicalHistory'],
      profileImagePath: map['profileImagePath'],
      documentPath: map['documentPath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Copy with method for updates
  Patient copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? email,
    String? address,
    String? bloodGroup,
    String? medicalHistory,
    String? profileImagePath,
    String? documentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      documentPath: documentPath ?? this.documentPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
