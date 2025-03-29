import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';

class ChatWebSocketService {
  final IOWebSocketChannel channel;
  Function(Map<String, dynamic>)? _onNewMessage;

  ChatWebSocketService(String token)
      : channel = IOWebSocketChannel.connect(
          Uri.parse('$WEBSOCKET_URL/chat?token=$token'),
        ) {
    print('Chat WebSocket подключён');
    channel.stream.listen(
      (message) {
        print('Received message: $message');
        final data = jsonDecode(message as String);
        if (data['event'] == 'new_message') {
          _onNewMessage?.call(data['data']);
        }
      },
      onError: (error) => print('Chat WebSocket error: $error'),
      onDone: () => print('Chat WebSocket отключён'),
    );
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _onNewMessage = callback;
  }

  void sendMessage(String text) {
    final data = {"message": text}; // Формат для жителя
    channel.sink.add(jsonEncode(data));
    print('Sent message: $data');
  }

  void disconnect() {
    channel.sink.close();
  }
}
