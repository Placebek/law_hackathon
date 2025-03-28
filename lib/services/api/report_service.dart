import 'api_service.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getReports(String token) async {
    return _apiService.get('/reports', token);
  }
}
