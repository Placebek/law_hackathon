import 'api_service.dart';

class MessageService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getMessages(String token) async {
    try {
      final response = await _apiService.get('/ws/chat/messages', token);
      return response;
    } catch (e) {
      throw Exception('Ошибка получения сообщений: $e');
    }
  }
}
