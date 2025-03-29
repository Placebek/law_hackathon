class AccidentType {
  final int id;
  final String name;

  AccidentType({required this.id, required this.name});

  factory AccidentType.fromJson(Map<String, dynamic> json) {
    return AccidentType(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Другое',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
