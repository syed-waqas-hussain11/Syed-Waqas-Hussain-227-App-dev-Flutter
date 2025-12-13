class Submission {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final DateTime? createdAt;

  Submission({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
    };
  }

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'] as String?,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phone_number'] as String,
      address: map['address'] as String,
      gender: map['gender'] as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Submission copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? gender,
    DateTime? createdAt,
  }) {
    return Submission(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
