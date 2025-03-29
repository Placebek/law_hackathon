import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isWebSocketSetup = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isWebSocketSetup) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        // Если пользователь не авторизован, перенаправляем на страницу входа
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Пожалуйста, войдите в систему')),
          );
        });
      } else {
        _setupWebSocketListeners(authProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title:
                Text('Чат с полицией', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF1E88E5),
          ),
          body: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(child: Text('Сообщений нет'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUser = message['is_user'] ?? false;
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Color(0xFF1E88E5)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                message['content'] ?? 'Сообщение отсутствует',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isUser ? Colors.white : Colors.black87,
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
                          hintText: 'Введите сообщение...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
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
      _isWebSocketSetup = true;
      authProvider.chatWebSocketService!.onNewMessage((data) {
        print('Получено новое сообщение: $data');
        setState(() {
          _messages.add({
            'content': data['content'] ?? 'Сообщение отсутствует',
            'is_user': data['is_user'] ?? false,
          });
          _scrollToBottom();
        });
      });
    } else {
      print('Ошибка: chatWebSocketService не инициализирован');
      // Откладываем показ SnackBar до завершения построения
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Чат недоступен: WebSocket не инициализирован')),
        );
      });
    }
  }

  void _sendMessage(AuthProvider authProvider) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && authProvider.chatWebSocketService != null) {
      authProvider.chatWebSocketService!.sendMessage(message);
      setState(() {
        _messages.add({
          'content': message,
          'is_user': true,
        });
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
    super.dispose();
  }
}
