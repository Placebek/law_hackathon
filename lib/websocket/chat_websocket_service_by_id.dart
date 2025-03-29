import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../utils/constants.dart';

class ChatWebSocketServiceById {
  final IOWebSocketChannel _channel;
  Function(Map<String, dynamic>)? _onNewMessage;

  /// Создаёт WebSocket-сервис для чата с конкретным [chatId].
  /// [token] — токен аутентификации.
  /// [chatId] — идентификатор чата.
  ChatWebSocketServiceById({
    required String token,
    required String chatId,
  }) : _channel = IOWebSocketChannel.connect(
          Uri.parse('$WEBSOCKET_URL/chat/$chatId/messages?token=$token'),
        ) {
    print('Chat WebSocket подключён к $WEBSOCKET_URL/chat/$chatId/messages');
    _setupListeners();
  }

  void _setupListeners() {
    _channel.stream.listen(
      (message) {
        try {
          print('Получено сообщение: $message');
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          if (data['event'] == 'new_message') {
            _onNewMessage?.call(data['data'] as Map<String, dynamic>);
          }
        } catch (e) {
          print('Ошибка обработки сообщения: $e');
        }
      },
      onError: (error) {
        print('Ошибка WebSocket: $error');
      },
      onDone: () {
        print('Chat WebSocket отключён');
      },
      cancelOnError: false,
    );
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _onNewMessage = callback;
  }

  void sendMessage(String text) {
    final data = {'message': text};
    try {
      _channel.sink.add(jsonEncode(data));
      print('Отправлено сообщение: $data');
    } catch (e) {
      print('Ошибка отправки сообщения: $e');
    }
  }

  void disconnect() {
    _channel.sink.close();
    print('Chat WebSocket закрыт');
  }
}
