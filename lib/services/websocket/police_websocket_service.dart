import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';

class PoliceWebSocketService {
  final IOWebSocketChannel channel;
  Function(List<Map<String, dynamic>>)? _onAllMessages;

  PoliceWebSocketService(String token)
    : channel = IOWebSocketChannel.connect(
        Uri.parse('$WEBSOCKET_URL/police/chats?token=$token'),
      ) {
    print('Police WebSocket подключён');
    channel.stream.listen(
      (message) {
        final data = jsonDecode(message as String);
        switch (data['event']) {
          case 'all_messages':
            _onAllMessages?.call(List<Map<String, dynamic>>.from(data['data']));
            break;
          default:
            print('Неизвестное событие в Police WebSocket: ${data['event']}');
        }
      },
      onError: (error) => print('Police WebSocket error: $error'),
      onDone: () => print('Police WebSocket отключён'),
    );
  }

  void onAllMessages(Function(List<Map<String, dynamic>>) callback) {
    _onAllMessages = callback;
  }

  void disconnect() {
    channel.sink.close();
  }
}
