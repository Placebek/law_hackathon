import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/verification_request.dart';
import 'models/register_request.dart';
import 'models/register_response.dart';
import 'token_manager.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.75.31:8000';

  // Отправка email для получения кода
  Future<bool> sendEmail(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/send_email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Ошибка отправки email: ${response.body}');
    }
  }

  // Проверка кода
  Future<bool> verifyCode(VerificationRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Ошибка верификации: ${response.body}');
    }
  }

  // Регистрация
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final data = RegisterResponse.fromJson(jsonDecode(response.body));
      await TokenManager.saveToken(data.accessToken);
      return data;
    } else {
      throw Exception('Ошибка регистрации: ${response.body}');
    }
  }

  // Логин
  Future<RegisterResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = RegisterResponse.fromJson(jsonDecode(response.body));
      await TokenManager.saveToken(data.accessToken); // Сохраняем токен
      return data;
    } else {
      throw Exception('Ошибка входа: ${response.body}');
    }
  }

  // Пример GET-запроса
  Future<String> getProtectedData() async {
    final token = await TokenManager.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/some_protected_endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Ошибка получения данных: ${response.body}');
    }
  }

  // Пример PATCH-запроса
  Future<void> updateUserData(String field, String value) async {
    final token = await TokenManager.getToken();
    final response = await http.patch(
      Uri.parse('$_baseUrl/user/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({field: value}),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления: ${response.body}');
    }
  }
}
