import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/crime.dart';

class CrimeService {
  static const String _baseUrl = 'http://192.168.9.31:8000';

  Future<List<Crime>> getCrimes({
    required double latitude,
    required double longitude,
    required double distance,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/p/crime/all_crimes?latitude=$latitude&longitude=$longitude&distance=$distance'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Crime.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка получения данных: ${response.body}');
    }
  }
}
