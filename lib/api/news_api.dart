import 'dart:convert';
import 'package:http/http.dart' as http;
import './models/news_models.dart';

class NewsApi {
  static const String baseUrl = 'https:// 192.168.43.31/v1';

  static Future<List<News>> fetchAllNews() async {
    final response = await http.get(Uri.parse('$baseUrl/all_news'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки новостей');
    }
  }

  static Future<News> fetchNewsById(int newsId) async {
    final response = await http.get(Uri.parse('$baseUrl/news/$newsId'));

    if (response.statusCode == 200) {
      return News.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка загрузки новости');
    }
  }
}
