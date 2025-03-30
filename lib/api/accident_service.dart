import 'package:law_code_flutter/api/models/accident.dart';

import 'api_service.dart';

class AccidentService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getAccidentTypes(String token) async {
    return _apiService.get('/v1/incident_types/all', token);
  }

  Future<Map<String, dynamic>> addAccident(
      Accident accident, String token) async {
    Map<String, String> accidentFormData = accident.toFormData();

    return _apiService.postMultipart(
        '/v1/add-incident', accidentFormData, accident.photo, token);
  }
}
