class RegisterRequest {
  final String firstName;
  final String lastName;
  final String uin;
  final String email;
  final String phoneNumber;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.uin,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'uin': uin,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      };
}
