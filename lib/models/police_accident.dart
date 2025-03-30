class PoliceAccident {
  final int id;
  final String title;
  final String description;
  final String photo;
  final String video;
  final String incidentTypeName;
  final String userFirstName;
  final String userLastName;
  final String userEmail;
  final DateTime createdAt;

  PoliceAccident({
    required this.id,
    required this.title,
    required this.description,
    required this.photo,
    required this.video,
    required this.incidentTypeName,
    required this.userFirstName,
    required this.userLastName,
    required this.userEmail,
    required this.createdAt,
  });

  factory PoliceAccident.fromJson(Map<String, dynamic> json) {
    return PoliceAccident(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      photo: json['photo'],
      video: json['video'],
      incidentTypeName: json['incident_type']['type_name'],
      userFirstName: json['user']['first_name'],
      userLastName: json['user']['last_name'],
      userEmail: json['user']['email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
