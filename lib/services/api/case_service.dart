import 'api_service.dart';

class CaseService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getCases(String token) async {
    return _apiService.get('/cases', token);
  }
}
