import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';
import '../notification/notification_service.dart';

class ChatWebSocketService {
  final IOWebSocketChannel channel;
  Function(Map<String, dynamic>)? _onNewMessage;

  ChatWebSocketService(String token)
      : channel = IOWebSocketChannel.connect(
            Uri.parse('$WEBSOCKET_URL/chat?token=$token')) {
    print('Chat WebSocket подключён');
    channel.stream.listen(
      (message) {
        print('Received message: $message');
        final data = jsonDecode(message as String);
        if (data['event'] == 'new_message') {
          _onNewMessage?.call(data['data']);
          NotificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: 'Новое сообщение от полиции',
            body: data['data']['content'],
          );
        } else if (data['event'] == 'chat_messages') {
          print('Received chat history: ${data['data']}');
          for (var msg in data['data']) {
            _onNewMessage?.call({
              'content': msg['content'],
              'fromUserId': msg['sender_id'],
              'role': msg['role'],
            });
          }
        }
      },
      onError: (error) => print('Chat WebSocket error: $error'),
      onDone: () => print('Chat WebSocket отключён'),
    );
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _onNewMessage = callback;
  }

  void sendMessage(String toUserId, String text) {
    final data = {
      'event': 'message',
      'data': {'toUserId': '1', 'text': text, 'role': 'user'},
    };
    channel.sink.add(jsonEncode(data));
    print('Sent message: $data');
  }

  void disconnect() {
    channel.sink.close();
  }
}
