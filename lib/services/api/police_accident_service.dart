import 'api_service.dart';

class PoliceAccidentService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getAllPoliceAccidents(String token) async {
    return _apiService.get('/v1/all_incidents', token);
  }

  Future<Map<String, dynamic>> getOnePoliceAccident(
    int accidentId,
    String token,
  ) async {
    return _apiService.getOne('/v1/incident/${accidentId}', token);
  }
}
