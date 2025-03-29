// import 'dart:convert';
// import 'package:web_socket_channel/io.dart';

// class WebSocketService {
//   late IOWebSocketChannel _channel;
//   final Map<String, Function(dynamic)> _listeners = {};

//   WebSocketService(String token) {
//     _channel = IOWebSocketChannel.connect(
//       Uri.parse('ws://192.168.43.31:8000/v1/ws/chat?token=$token'),
//     );
//     _setupListeners();
//     print('WebSocketService initialized with token: $token');
//   }

//   void _setupListeners() {
//     _channel.stream.listen(
//       (data) {
//         print('Received message: $data');
//         if (_listeners['newMessage'] != null) {
//           _listeners['newMessage']!(jsonDecode(data));
//         }
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//       },
//       onDone: () {
//         print('WebSocket disconnected');
//       },
//     );
//   }

//   void onNewMessage(Function(dynamic) callback) {
//     _listeners['newMessage'] = callback;
//   }

//   void sendMessage(String message) {
//     final payload = jsonEncode({
//       'message': message,
//     });
//     _channel.sink.add(payload);
//     print('Sent message: $payload');
//   }

//   void dispose() {
//     _channel.sink.close();
//     _listeners.clear();
//     print('WebSocket disposed');
//   }
// }
