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
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  void _loadChatMessages() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      print(
        'Инициализация ChatMessagesWebSocketService для chat_id=${widget.chatId}',
      );
      authProvider.initializeChatMessagesWebSocket(
        authProvider.token!,
        widget.chatId,
      );
      if (authProvider.chatMessagesWebSocketService != null) {
        authProvider.chatMessagesWebSocketService!.onChatMessages((messages) {
          print('Получены сообщения чата: $messages');
          setState(() {
            _messages = messages;
            _scrollToBottom();
          });
        });
      } else {
        print('Ошибка: chatMessagesWebSocketService не инициализирован');
      }
    } else {
      print('Ошибка: токен отсутствует');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!_isWebSocketSetup && authProvider.chatWebSocketService != null) {
          _setupWebSocketListeners(authProvider);
          _isWebSocketSetup = true;
        }

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
                            final isPoliceman = !(message['is_user'] ?? false);
                            return Align(
                              alignment:
                                  isPoliceman
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
                                      isPoliceman
                                          ? Color(0xFF1E88E5)
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  message['content'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isPoliceman
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

  void _setupWebSocketListeners(AuthProvider authProvider) {
    if (authProvider.chatWebSocketService != null) {
      authProvider.chatWebSocketService!.onNewMessage((data) {
        if (data['fromUserId'] == widget.senderId) {
          print('Новое сообщение в реальном времени: ${data['content']}');
          setState(() {
            _messages.add({
              'content': data['content'],
              'is_user': data['is_user'],
            });
            _scrollToBottom();
          });
        }
      });
      authProvider.chatWebSocketService!.onIncomingCall((data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Входящий звонок от ${data['fromUserId']}')),
        );
      });
      authProvider.chatWebSocketService!.authenticate(authProvider.username!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Чат недоступен: WebSocket не инициализирован')),
      );
    }
  }

  void _sendMessage(AuthProvider authProvider) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty &&
        authProvider.chatWebSocketService != null &&
        authProvider.username != null) {
      authProvider.chatWebSocketService!.sendMessage(widget.senderId, message);
      setState(() {
        _messages.add({'content': message, 'is_user': false});
      });
      _messageController.clear();
      _scrollToBottom();
    } else {
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    Provider.of<AuthProvider>(
      context,
      listen: false,
    ).chatMessagesWebSocketService?.disconnect();
    super.dispose();
  }
}
