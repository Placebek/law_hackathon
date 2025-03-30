class Statement {
  final String recipient;
  final String text;
  final int statementTypeId;
  final bool anonymous;

  Statement({
    required this.recipient,
    required this.text,
    required this.statementTypeId,
    required this.anonymous,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    return Statement(
      recipient: json['recipient'] ?? 'Без имени',
      text: json['text'] ?? '',
      statementTypeId: json['type_id'] ?? 0,
      anonymous: json['anonymous'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient': recipient,
      'text': text,
      'type_id': statementTypeId,
      'anonymous': anonymous,
    };
  }
}
