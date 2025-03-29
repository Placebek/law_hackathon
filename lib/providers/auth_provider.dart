import 'package:flutter/material.dart';
import 'package:law_hackathon_flutter/services/websocket/police_websocket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api/auth_service.dart';
import '../services/websocket/chat_websocket_service.dart';
import '../services/websocket/chat_messages_websocket_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _verificationToken;
  String? _tokenExpireTime;
  final AuthService _authService = AuthService();
  ChatWebSocketService? _chatWebSocketService;
  ChatMessagesWebSocketService? _chatWebSocketServiceById;
  PoliceWebSocketService? _policeWebSocketService;
  // Добавляем хранилище сообщений по chatId
  Map<String, List<Map<String, dynamic>>> _messagesByChatId = {};
  List<Map<String, dynamic>> _allMessages = [];

  bool get isAuthenticated => _token != null;
  String? get username => _username;
  String? get token => _token;
  ChatWebSocketService? get chatWebSocketService => _chatWebSocketService;
  PoliceWebSocketService? get policeWebSocketService => _policeWebSocketService;
  ChatMessagesWebSocketService? get chatWebSocketServiceById =>
      _chatWebSocketServiceById;
  // Добавляем геттер для сообщений
  Map<String, List<Map<String, dynamic>>> get messagesByChatId =>
      _messagesByChatId;
  List<Map<String, dynamic>> get allMessages => _allMessages;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    _username = prefs.getString('username');
    _tokenExpireTime = prefs.getString('access_token_expire_time');
    if (_token != null) {
      _initializeWebSocket(_token!);
    }
    notifyListeners();
  }

  Future<String> sendVerification(String email) async {
    try {
      final response = await _authService.sendVerification(email);
      _verificationToken = response['access_token'];
      _tokenExpireTime = response['access_token_expire_time'];
      _username = email;
      notifyListeners();
      return 'Код верификации отправлен';
    } catch (e) {
      throw Exception('Ошибка отправки кода: $e');
    }
  }

  Future<void> verifyCode(String code) async {
    if (_username == null || _verificationToken == null) {
      throw Exception('Email или токен верификации отсутствует');
    }
    // try {
    final response = await _authService.verifyCode(
      _verificationToken!,
      code = code,
    );
    _token = response['access_token'];
    _tokenExpireTime = response['access_token_expire_time'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _token!);
    await prefs.setString('username', _username!);
    await prefs.setString('access_token_expire_time', _tokenExpireTime!);
    _initializeWebSocket(_token!);
    _verificationToken = null;
    notifyListeners();
    // } catch (e) {
    //   throw Exception('Ошибка верификации: $e');
    // }
  }

  Future<void> setToken(
    String token,
    String username, {
    String? expireTime,
  }) async {
    _token = token;
    _username = username;
    _tokenExpireTime = expireTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _token!);
    await prefs.setString('username', _username!);
    if (_tokenExpireTime != null) {
      await prefs.setString('access_token_expire_time', _tokenExpireTime!);
    }
    _initializeWebSocket(_token!);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _verificationToken = null;
    _tokenExpireTime = null;
    _messagesByChatId.clear();
    _allMessages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('username');
    await prefs.remove('access_token_expire_time');
    _chatWebSocketService?.disconnect();
    _chatWebSocketServiceById?.disconnect();
    _chatWebSocketService = null;
    _chatWebSocketServiceById = null;
    notifyListeners();
  }

  void _initializeWebSocket(String token) {
    _chatWebSocketService = ChatWebSocketService(token);
    print('ChatWebSocketService инициализирован с токеном: $token');
    _setupChatWebSocketListeners();
  }

  // Добавляем метод initializeChatById
  void initializeChatById(String token, String chatId) {
    _chatWebSocketServiceById = ChatMessagesWebSocketService(
      token,
      int.parse(chatId),
    );
    print('ChatWebSocketServiceById инициализирован для chatId: $chatId');
    _setupChatByIdWebSocketListeners(chatId);
  }

  void _setupChatWebSocketListeners() {
    if (_chatWebSocketService != null) {
      _chatWebSocketService!.onNewMessage((data) {
        print('Новое сообщение из общего чата: $data');
        _addMessage(data);
      });
    }
  }

  void _setupChatByIdWebSocketListeners(String chatId) {
    if (_chatWebSocketServiceById != null) {
      _chatWebSocketServiceById!.onNewMessage((data) {
        print('Новое сообщение для chatId $chatId: $data');
        _addMessage(data, chatId: chatId);
      });
      // Запрашиваем сообщения для конкретного chatId
      _chatWebSocketServiceById!.sendMessage('{"event": "get_chat_messages"}');
    }
  }

  void _addMessage(Map<String, dynamic> data, {String? chatId}) {
    final messageChatId = chatId ?? data['chat_id']?.toString();
    if (messageChatId != null) {
      if (!_messagesByChatId.containsKey(messageChatId)) {
        _messagesByChatId[messageChatId] = [];
      }
      final senderId =
          data['sender_id']?.toString() ?? data['fromUserId']?.toString();
      final isFromCurrentUser = senderId == _username;
      _messagesByChatId[messageChatId]!.add({
        'content': data['content'],
        'sender_id': senderId,
        'is_from_current_user': isFromCurrentUser,
        'chat_id': messageChatId,
      });
      notifyListeners();
    }
  }

  void _setupWebSocketListeners() {
    if (_policeWebSocketService != null) {
      _policeWebSocketService!.onAllMessages((messages) {
        print('Получены все сообщения: $messages');
        _allMessages = messages;
        notifyListeners();
      });
      _policeWebSocketService!.onNewMessage((data) {
        print('Получено новое сообщение: $data');
        _allMessages.add(data);
        notifyListeners();
      });
    }
  }
}
