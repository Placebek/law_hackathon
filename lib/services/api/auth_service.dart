import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> sendVerification(String email) async {
    return _apiService.post('/api/police/send-verification', {'email': email});
  }

  Future<Map<String, dynamic>> verifyCode(String token, String code) async {
    return _apiService.post('/api/police/verify/$token', {'code': code});
  }
}
