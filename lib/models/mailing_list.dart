class MailingList {
  final String title;
  final String description;
  final String? author;
  final String? photo;

  MailingList({
    required this.title,
    required this.description,
    this.author,
    this.photo,
  });

  factory MailingList.fromJson(Map<String, dynamic> json) {
    return MailingList(
      title: json['title'],
      description: json['description'],
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'photo': photo};
  }
}
