import 'package:http/http.dart' as http;
import 'package:law_code_flutter/api/models/register_request.dart';
import 'dart:convert';
import 'models/verification_request.dart';

class AuthService {
  final String _baseUrl = 'http://192.168.43.31:8000';

  Future<Map<String, dynamic>> sendEmail(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/user/send_email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка отправки email: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyCode(String token, String code) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/user/verify/$token'), // Токен в пути
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка верификации: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/user/register'),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка регистрации: ${response.body}');
    }
  }

  Future<dynamic> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Не удалось войти: ${response.body}');
    }
  }
}
