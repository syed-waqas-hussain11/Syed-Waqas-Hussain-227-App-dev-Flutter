class Contact {
  int? id;
  String name;
  String email;
  int age;
  String? imagePath;

  Contact({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'age': age,
      'imagePath': imagePath,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      age: map['age'] is int
          ? map['age'] as int
          : int.tryParse(map['age'].toString()) ?? 0,
      imagePath: map['imagePath'] as String?,
    );
  }

  Contact copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
    String? imagePath,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
