import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PoliceChatPage extends StatefulWidget {
  final String senderId;
  final int chatId;

  PoliceChatPage({required this.senderId, required this.chatId});

  @override
  _PoliceChatPageState createState() => _PoliceChatPageState();
}

class _PoliceChatPageState extends State<PoliceChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isWebSocketSetup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!_isWebSocketSetup && authProvider.token != null) {
      authProvider.initializeChatById(
        authProvider.token!,
        widget.chatId.toString(),
      );
      _isWebSocketSetup = true;
      _messages = authProvider.messagesByChatId[widget.chatId.toString()] ?? [];
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        _messages =
            authProvider.messagesByChatId[widget.chatId.toString()] ?? [];
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Чат с жителем ${widget.senderId}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF1E88E5),
          ),
          body: Column(
            children: [
              Expanded(
                child:
                    _messages.isEmpty
                        ? Center(child: Text('Сообщений нет'))
                        : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(10),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isFromCurrentUser =
                                message['role'] == 'police';
                            return Align(
                              alignment:
                                  isFromCurrentUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isFromCurrentUser
                                          ? Color(0xFF1E88E5)
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  message['content'] ?? 'Сообщение отсутствует',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isFromCurrentUser
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
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
                          hintText: 'Введите ответ...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
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

  void _sendMessage(AuthProvider authProvider) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      authProvider.sendChatMessage(message, widget.chatId.toString());
      _messageController.clear();
      _scrollToBottom();
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
