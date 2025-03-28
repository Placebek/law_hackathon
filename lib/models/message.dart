class Message {
  final String text;
  final String from;

  Message({required this.text, required this.from});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(text: json['text'], from: json['from'] ?? 'Unknown');
  }
}
