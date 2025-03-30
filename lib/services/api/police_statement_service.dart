import 'api_service.dart';

class PoliceStatementService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getAllPoliceStatements(String token) async {
    return _apiService.get('/v1/im-policeman/my-statemants', token);
  }

  Future<Map<String, dynamic>> getOnePoliceStatement(
    int statementId,
    String token,
  ) async {
    return _apiService.getOne('/v1/statement/${statementId}', token);
  }
}
