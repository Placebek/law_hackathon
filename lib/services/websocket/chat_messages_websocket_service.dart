import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';

class ChatMessagesWebSocketService {
  final IOWebSocketChannel channel;
  Function(List<Map<String, dynamic>>)? _onChatMessages;
  Function(Map<String, dynamic>)?
  _onNewMessage; // Добавляем для новых сообщений

  ChatMessagesWebSocketService(String token, int chatId)
    : channel = IOWebSocketChannel.connect(
        Uri.parse('$WEBSOCKET_URL/chat/$chatId/messages?token=$token'),
      ) {
    print('ChatMessages WebSocket подключён для chat_id=$chatId');
    channel.stream.listen(
      (message) {
        print('Получено сообщение от WebSocket: $message');
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        switch (data['event']) {
          case 'chat_messages':
            print('Обработка события chat_messages: ${data['data']}');
            _onChatMessages?.call(
              List<Map<String, dynamic>>.from(data['data']),
            );
            break;
          case 'new_message':
            print('Обработка события new_message: ${data['data']}');
            _onNewMessage?.call(data['data'] as Map<String, dynamic>);
            break;
          default:
            print(
              'Неизвестное событие в ChatMessages WebSocket: ${data['event']}',
            );
        }
      },
      onError: (error) {
        print('ChatMessages WebSocket ошибка: $error');
      },
      onDone: () {
        print('ChatMessages WebSocket отключён');
      },
    );
  }

  void onChatMessages(Function(List<Map<String, dynamic>>) callback) {
    _onChatMessages = callback;
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _onNewMessage = callback;
  }

  void sendMessage(String text) {
    final data = {'message': text};
    try {
      channel.sink.add(jsonEncode(data));
      print('Отправлено сообщение: $data');
    } catch (e) {
      print('Ошибка отправки сообщения: $e');
    }
  }

  void disconnect() {
    channel.sink.close();
    print('ChatMessages WebSocket закрыт');
  }
}
