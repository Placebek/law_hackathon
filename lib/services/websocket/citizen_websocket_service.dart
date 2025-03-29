import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';

class CitizenWebSocketService {
  final IOWebSocketChannel channel;
  Function(Map<String, dynamic>)? _onNewMessage;

  CitizenWebSocketService(String token)
    : channel = IOWebSocketChannel.connect(
        Uri.parse('$WEBSOCKET_URL/chat?token=$token'),
      ) {
    print('Citizen WebSocket подключён');
    channel.stream.listen(
      (message) {
        final data = jsonDecode(message as String);
        switch (data['event']) {
          case 'new_message':
            _onNewMessage?.call(data['data']);
            break;
          default:
            print('Неизвестное событие для жителя: ${data['event']}');
        }
      },
      onError: (error) => print('Citizen WebSocket error: $error'),
      onDone: () => print('Citizen WebSocket отключён'),
    );
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _onNewMessage = callback;
  }

  void sendMessage(String text) {
    final data = {'message': text};
    channel.sink.add(jsonEncode(data));
  }

  void disconnect() {
    channel.sink.close();
  }
}
