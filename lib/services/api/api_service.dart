import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class ApiService {
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$BASE_URL$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка: ${response.body}');
    }
  }

  Future<List<dynamic>> get(String endpoint, String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      print('Получен ответ: ${response.body}');
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Ошибка: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getOne(String endpoint, String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Ошибка: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> postToken(
    String endpoint,
    Map<String, dynamic> body,
    String token, // Добавили опциональный токен
  ) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Добавляем токен, если есть
    };

    final response = await http.post(
      Uri.parse('$BASE_URL$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка: ${response.body}');
    }
  }
}
