enum Role { USER, ADMIN, PROFESSOR }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String registration; // Matrícula
  final Role role;
  final String? course;
  final String? campus;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.registration,
    this.role = Role.USER,
    this.course,
    this.campus,
  });

  // Factory for creating a user from JSON (simulating backend response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      registration: json['registration'],
      role: Role.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => Role.USER,
      ),
      course: json['course'],
      campus: json['campus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'registration': registration,
      'role': role.name,
      'course': course,
      'campus': campus,
    };
  }
}
