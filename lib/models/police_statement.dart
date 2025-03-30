class PoliceStatement {
  final int id;
  final String recipient;
  final String text;
  final DateTime createdAt;
  final bool anonymous;
  final String typeName;
  final String status;
  final String citizenName;

  PoliceStatement({
    required this.id,
    required this.recipient,
    required this.text,
    required this.createdAt,
    required this.anonymous,
    required this.typeName,
    required this.status,
    required this.citizenName,
  });

  factory PoliceStatement.fromJson(Map<String, dynamic> json) {
    return PoliceStatement(
      id: json['id'],
      recipient: json['recipient'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      anonymous: json['anonymous'],
      typeName: json['type']['type_name'],
      status: json['status'],
      citizenName:
          json['anonymous']
              ? "Аноним"
              : "${json['user']['first_name']} ${json['user']['last_name']}",
    );
  }
}
