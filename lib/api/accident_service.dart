import 'package:law_code_flutter/api/models/accident.dart';

import 'api_service.dart';

class AccidentService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getAccidentTypes(String token) async {
    return _apiService.get('/v1/incident_types/all', token);
  }

  Future<Map<String, dynamic>> addAccident(
      Accident accident, String token) async {
    final Map<String, dynamic> body = accident.toJson();
    return _apiService.post(
        '/v1/accidents/add', body); // Предполагаемый эндпоинт
  }
}
