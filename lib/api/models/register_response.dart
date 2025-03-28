class RegisterResponse {
  final String accessToken;
  final String accessTokenExpireTime;

  RegisterResponse({
    required this.accessToken,
    required this.accessTokenExpireTime,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      accessToken: json['access_token'],
      accessTokenExpireTime: json['access_token_expire_time'],
    );
  }
}
