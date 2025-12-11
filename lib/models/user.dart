class User {
  final String id;
  final String email;
  final String name;
  final String role; // admin, cashier, barista

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'cashier',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    role: json['role'] as String? ?? 'cashier',
  );
}
