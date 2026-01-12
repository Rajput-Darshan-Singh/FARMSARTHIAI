class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? location;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.location,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
    };
  }
}