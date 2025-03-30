import 'package:flutter/material.dart';
import '../websocket/chat_websocket_service.dart';

class ChatPage extends StatefulWidget {
  final String token;
  const ChatPage({required this.token});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  late ChatWebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();
    _webSocketService = ChatWebSocketService(widget.token);
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    _webSocketService.onNewMessage((data) {
      setState(() {
        _messages.add({
          'sender_id': data['fromUserId'],
          'content': data['content'],
          'role': data['role'],
        });
        _scrollToBottom();
      });
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _webSocketService.sendMessage(
          'police', message); // Замените 'police' на реальный ID
      setState(() {
        _messages.add({
          'sender_id': 'resident', // Замените на реальный ID жителя
          'content': message,
          'role': 'user',
        });
        _messageController.clear();
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат с полицией', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isUser ? Color(0xFF1E88E5) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['content'],
                      style: TextStyle(
                          fontSize: 16,
                          color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                    maxLines: 1,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF1E88E5)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
