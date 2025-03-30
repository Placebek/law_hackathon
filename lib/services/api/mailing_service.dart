import 'package:law_hackathon_flutter/models/mailing_list.dart';

import 'api_service.dart';

class MailingService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> sendMailingList(
    MailingList mailingList,
    String token,
  ) async {
    Map<String, dynamic> mailingListJson = mailingList.toJson();
    return _apiService.postToken(
      '/v1/mailing/police/send',
      mailingListJson,
      token,
    );
  }
}
