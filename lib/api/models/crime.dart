class Crime {
  final int id;
  final double latitude;
  final double longitude;

  Crime({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  factory Crime.fromJson(Map<String, dynamic> json) {
    // Предполагаем, что geoposition содержит координаты в формате "lat,lng"
    final geo = json['geoposition'] as String;
    final coords = geo.split(',');
    return Crime(
      id: json['id'] as int,
      latitude: double.parse(coords[0]),
      longitude: double.parse(coords[1]),
    );
  }
}
