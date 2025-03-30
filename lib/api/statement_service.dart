import 'models/statement.dart';
import 'api_service.dart';

class StatementService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getStatementTypes(String token) async {
    return _apiService.get('/v1/statement/all-types', token);
  }

  Future<Map<String, dynamic>> addStatement(
      Statement statement, String token) async {
    Map<String, dynamic> statementJson = statement.toJson();

    return _apiService.postToken('/v1/add-statement', statementJson, token);
  }
}
