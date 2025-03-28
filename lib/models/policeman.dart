class Policeman {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  Policeman({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Policeman.fromJson(Map<String, dynamic> json) {
    return Policeman(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }
}
