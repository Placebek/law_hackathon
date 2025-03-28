import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _isWebSocketSetup = false;

  @override
  void initState() {
    super.initState();
    // Ничего не делаем в initState, чтобы избежать проблем с context
  }

  void _setupWebSocketListeners(AuthProvider authProvider) {
    if (!_isWebSocketSetup && authProvider.webSocketService != null) {
      authProvider.webSocketService!.onNewMessage((data) {
        setState(() {
          _messages.add({
            'sender': 'Полиция',
            'text': data['text'],
          });
          _scrollToBottom();
        });
      });
      _isWebSocketSetup = true;
    }
  }

  void _sendMessage(AuthProvider authProvider) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && authProvider.webSocketService != null) {
      authProvider.webSocketService!.sendMessage('police', message);
      setState(() {
        _messages.add({
          'sender': 'Вы',
          'text': message,
        });
        _messageController.clear();
        _scrollToBottom();
      });
    } else if (authProvider.webSocketService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Чат недоступен: WebSocket не инициализирован')),
      );
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Настраиваем WebSocket только один раз при первом построении
        _setupWebSocketListeners(authProvider);

        return Scaffold(
          appBar: AppBar(
            title:
                Text('Чат с полицией', style: TextStyle(color: Colors.white)),
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
                    final isUser = message['sender'] == 'Вы';
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? Color(0xFF1E88E5) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['sender']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isUser ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              message['text']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                        ),
                        maxLines: 1,
                        onSubmitted: (_) => _sendMessage(authProvider),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.send, color: Color(0xFF1E88E5)),
                      onPressed: () => _sendMessage(authProvider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
