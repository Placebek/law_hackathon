import 'api_service.dart';

class MessageService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getMessages(String token) async {
    return _apiService.get('/messages', token);
  }
}
