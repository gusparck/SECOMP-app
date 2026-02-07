import '../../shared/models/user_model.dart';

class AuthService {
  // Simulates a login API call
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return UserModel(
      id: "mock-id-123",
      name: "Pedro Henrique", // Mocked name for login
      email: email,
      registration: "2023001234",
      course: "Ciência da Computação",
      campus: "Ouro Preto",
      role: Role.USER,
    );
  }

  // Simulates a register API call
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String registration,
    String? course,
    String? campus,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return UserModel(
      id: "mock-new-id-456",
      name: name,
      email: email,
      registration: registration,
      course: course,
      campus: campus,
      role: Role.USER,
    );
  }
}
