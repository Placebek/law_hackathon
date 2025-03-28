import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../utils/constants.dart';

class WebSocketService {
  late IO.Socket socket;

  WebSocketService() {
    socket = IO.io(WEBSOCKET_URL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) => print('WebSocket подключён'));
    socket.onDisconnect((_) => print('WebSocket отключён'));
  }

  void authenticate(String token) {
    socket.emit('auth', token);
  }

  void onIncomingCall(Function(Map<String, dynamic>) callback) {
    socket.on('incoming_call', (data) => callback(data));
  }

  void onNewMessage(Function(Map<String, dynamic>) callback) {
    socket.on('new_message', (data) => callback(data));
  }

  void makeCall(String toUserId, String fromUserId) {
    socket.emit('call', {'toUserId': toUserId, 'fromUserId': fromUserId});
  }

  void sendMessage(String toUserId, String text) {
    socket.emit('message', {'toUserId': toUserId, 'text': text});
  }

  void disconnect() {
    socket.disconnect();
  }
}
