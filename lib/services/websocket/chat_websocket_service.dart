import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';

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
        final data = jsonDecode(message as String);
        switch (data['event']) {
          case 'incoming_call':
            _onIncomingCall?.call(data['data']);
            break;
          case 'new_message':
            _onNewMessage?.call(data['data']);
            break;
          case 'auth_success':
            print('Аутентификация успешна: ${data['data']}');
            break;
          default:
            print('Неизвестное событие в Chat WebSocket: ${data['event']}');
        }
      },
      onError: (error) => print('Chat WebSocket error: $error'),
      onDone: () => print('Chat WebSocket отключён'),
    );
  }

  void authenticate(String token) {
    final data = {
      'event': 'auth',
      'data': {'token': token},
    };
    channel.sink.add(jsonEncode(data));
  }

  void onIncomingCall(Function(Map<String, dynamic>) callback) {
    _onIncomingCall = callback;
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _onNewMessage = callback;
  }

  void makeCall(String toUserId, String fromUserId) {
    final data = {
      'event': 'call',
      'data': {'toUserId': toUserId, 'fromUserId': fromUserId},
    };
    channel.sink.add(jsonEncode(data));
  }

  void sendMessage(String toUserId, String text) {
    final data = {
      'event': 'message',
      'data': {'toUserId': toUserId, 'text': text},
    };
    channel.sink.add(jsonEncode(data));
  }

  void disconnect() {
    channel.sink.close();
  }
}
