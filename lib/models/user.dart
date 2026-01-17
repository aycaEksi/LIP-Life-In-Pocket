class User {
  final int? id;
  final String email;
  final String password;
  final String? createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
// log ine basınca direkt giriyor şimdilik verification yapmadım daha
// tmm düzelttim -ayca

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}