import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';

class PoliceWebSocketService {
  final IOWebSocketChannel channel;
  Function(List<Map<String, dynamic>>)? _onAllMessages;
  Function(Map<String, dynamic>)? _onNewMessage;

  PoliceWebSocketService(String token)
    : channel = IOWebSocketChannel.connect(
        Uri.parse('$WEBSOCKET_URL/police?token=$token'), // Предполагаемый URL
      ) {
    print('Police WebSocket подключён');
    channel.stream.listen(
      (message) {
        print('Получено сообщение от WebSocket: $message');
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        switch (data['event']) {
          case 'all_messages':
            print('Обработка события all_messages: ${data['data']}');
            _onAllMessages?.call(List<Map<String, dynamic>>.from(data['data']));
            break;
          case 'new_message':
            print('Обработка события new_message: ${data['data']}');
            _onNewMessage?.call(data['data'] as Map<String, dynamic>);
            break;
          default:
            print('Неизвестное событие в Police WebSocket: ${data['event']}');
        }
      },
      onError: (error) {
        print('Police WebSocket ошибка: $error');
      },
      onDone: () {
        print('Police WebSocket отключён');
      },
    );
  }

  void onAllMessages(Function(List<Map<String, dynamic>>) callback) {
    _onAllMessages = callback;
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _onNewMessage = callback;
  }

  void requestAllMessages() {
    final request = jsonEncode({'event': 'get_all_messages'});
    try {
      channel.sink.add(request);
      print('Отправлен запрос на получение всех сообщений: $request');
    } catch (e) {
      print('Ошибка при отправке запроса: $e');
    }
  }

  void disconnect() {
    channel.sink.close();
    print('Police WebSocket закрыт');
  }
}
