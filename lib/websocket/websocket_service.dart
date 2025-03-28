import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  final IO.Socket _socket;
  final Map<String, Function(dynamic)> _listeners = {};

  WebSocketService(String token)
      : _socket = IO.io(
          'htphthtpthptphtphtptphpthpthptpthptphp',
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .setExtraHeaders({'Authorization': 'Bearer $token'})
              .disableAutoConnect()
              .build(),
        ) {
    _socket.connect();
    _setupListeners();
  }

  void _setupListeners() {
    _socket.on('newMessage', (data) {
      if (_listeners['newMessage'] != null) {
        _listeners['newMessage']!(data);
      }
    });
  }

  void onNewMessage(Function(dynamic) callback) {
    _listeners['newMessage'] = callback;
  }

  void sendMessage(String toUserId, String message) {
    _socket.emit('sendMessage', {
      'toUserId': toUserId,
      'text': message,
    });
  }

  void dispose() {
    _socket.disconnect();
    _listeners.clear();
  }
}
