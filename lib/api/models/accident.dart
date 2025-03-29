class Accident {
  final String title;
  final String description;
  final int incidentTypeId;
  final String photo;
  final String video;

  Accident({
    required this.title,
    required this.description,
    required this.incidentTypeId,
    required this.photo,
    required this.video,
  });

  factory Accident.fromJson(Map<String, dynamic> json) {
    return Accident(
      title: json['title'] ?? 'Без названия',
      description: json['description'] ?? '',
      incidentTypeId: json['incident_type_id'] ?? 0,
      photo: json['photo'] ?? '',
      video: json['video'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'incident_type_id': incidentTypeId,
      'photo': photo,
      'video': video,
    };
  }
}
