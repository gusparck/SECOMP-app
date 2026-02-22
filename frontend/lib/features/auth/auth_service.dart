import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user_model.dart';

class AuthService {
  // Use 10.0.2.2 for Android Emulator, or local IP for physical device
  static const String _baseUrl =
      'http://192.168.1.41:3000/api/user'; // Updated for local network access

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final loginResponse = LoginResponse.fromJson(data['data']);
      await _saveToken(loginResponse.token);
      await _saveUser(loginResponse.user);
      return loginResponse;
    } else {
      throw Exception(data['message'] ?? 'Erro ao realizar login.');
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String registration,
    String? course,
    String? campus,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'registration': registration,
        'course': course,
        'campus': campus,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(data['data']);
    } else if (response.statusCode == 400 && data['errors'] != null) {
      final Map<String, dynamic> errors = data['errors'];
      final Map<String, String> fieldErrors = {};

      errors.forEach((key, value) {
        if (value is Map && value.containsKey('_errors')) {
          final List<dynamic> errs = value['_errors'];
          if (errs.isNotEmpty) {
            fieldErrors[key] = errs.first.toString();
          }
        }
      });

      throw AuthException(
        message: data['message'] ?? 'Erro de validação',
        errors: fieldErrors,
      );
    } else {
      throw AuthException(
          message: data['message'] ?? 'Erro ao realizar cadastro.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null) {
      return UserModel.fromJson(jsonDecode(userStr));
    }
    return null;
  }
}

class AuthException implements Exception {
  final String message;
  final Map<String, String>? errors;

  AuthException({required this.message, this.errors});

  @override
  String toString() => message;
}

class LoginResponse {
  final UserModel user;
  final String token;

  LoginResponse({required this.user, required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
}
