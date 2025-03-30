class StatementType {
  final int id;
  final String name;

  StatementType({required this.id, required this.name});

  factory StatementType.fromJson(Map<String, dynamic> json) {
    return StatementType(
      id: json['id'] ?? 0,
      name: json['type_name'] ?? 'Другое',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
