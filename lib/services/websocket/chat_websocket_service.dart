import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';
import '../../notification/notification_service.dart';

class ChatWebSocketService {
  final IOWebSocketChannel channel;
  Function(Map<String, dynamic>)? _onIncomingCall;
  Function(Map<String, dynamic>)? _onNewMessage;

  ChatWebSocketService(String token)
    : channel = IOWebSocketChannel.connect(
        Uri.parse('$WEBSOCKET_URL/chat?token=$token'),
      ) {
    print('Chat WebSocket подключён');
    channel.stream.listen(
      (message) {
        print('Received messssssage: $message');
        final data = jsonDecode(message as String);
        switch (data['event']) {
          case 'incoming_call':
            _onIncomingCall?.call(data['data']);
            break;
          case 'new_message':
            _onNewMessage?.call(data['data']);
            final notificationService = NotificationService();
            notificationService.showNotification(
              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              title: 'Новое сообщение',
              body: data['data']['content'],
            );
            break;
          case 'auth_success':
            print('Аутентификация успешна: ${data['data']}');
            break;
          case 'chat_messages':
            print('Получена история сообщений: ${data['data']}');
            for (var msg in data['data']) {
              _onNewMessage?.call({
                'content': msg['content'],
                'fromUserId': msg['sender_id'],
                'role': msg['role'],
              });
            }
            break;
          default:
            print('Неизвестное событие в Chat WebSocket: ${data['event']}');
        }
      },
      onError: (error) => print('Chat WebSocket error: $error'),
      onDone: () => print('Chat WebSocket отключён'),
    );
  }

  void onIncomingCall(Function(Map<String, dynamic>) callback) {
    _onIncomingCall = callback;
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _onNewMessage = callback;
  }

  void makeCall(String toUserId) {
    final data = {
      'event': 'call',
      'data': {'toUserId': toUserId},
    };
    channel.sink.add(jsonEncode(data));
  }

  void sendMessage(String toUserId, String text) {
    final data = {
      'event': 'message',
      'data': {'toUserId': toUserId, 'text': text},
    };
    channel.sink.add(jsonEncode(data));
    print('Sent message: $data');
  }

  void disconnect() {
    channel.sink.close();
  }
}
