class News {
  final int id;
  final String text;
  final String date;
  final String image;

  News(
      {required this.id,
      required this.text,
      required this.date,
      required this.image});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      text: json['text'],
      date: json['date'],
      image: json['image'],
    );
  }
}
