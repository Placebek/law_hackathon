import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_service.dart';
import '../websocket/chat_websocket_service.dart';
import '../websocket/chat_websocket_service_by_id.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _verificationToken;
  String? _tokenExpireTime;
  final AuthService _authService = AuthService();
  ChatWebSocketService? _chatWebSocketService;
  ChatWebSocketServiceById? _chatWebSocketServiceById;
  Map<String, List<Map<String, dynamic>>> _messagesByChatId = {};

  bool get isAuthenticated => _token != null;
  String? get username => _username;
  String? get token => _token;
  ChatWebSocketService? get chatWebSocketService => _chatWebSocketService;
  ChatWebSocketServiceById? get chatWebSocketServiceById =>
      _chatWebSocketServiceById;
  Map<String, List<Map<String, dynamic>>> get messagesByChatId =>
      _messagesByChatId;

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
      final response = await _authService.sendEmail(email);
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
    try {
      final response = await _authService.verifyCode(code, _username!);
      _token = response['access_token'];
      _tokenExpireTime = response['access_token_expire_time'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _token!);
      await prefs.setString('username', _username!);
      await prefs.setString('access_token_expire_time', _tokenExpireTime!);
      _initializeWebSocket(_token!);
      _verificationToken = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка верификации: $e');
    }
  }

  Future<void> setToken(String token, String username,
      {String? expireTime}) async {
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

  void initializeChatById(String token, String chatId) {
    _chatWebSocketServiceById =
        ChatWebSocketServiceById(token: token, chatId: chatId);
    print('ChatWebSocketServiceById инициализирован для chatId: $chatId');
    _setupChatByIdWebSocketListeners(chatId);
  }

  void _setupChatWebSocketListeners() {
    if (_chatWebSocketService != null) {
      _chatWebSocketService!.onNewMessage((data) {
        print('Новое сообщение из общего чата: $data');
        final chatId = data['chat_id']?.toString();
        if (chatId != null) {
          if (!_messagesByChatId.containsKey(chatId)) {
            _messagesByChatId[chatId] = [];
          }
          _messagesByChatId[chatId]!.add(data);
          notifyListeners();
        }
      });
    }
  }

  void _setupChatByIdWebSocketListeners(String chatId) {
    if (_chatWebSocketServiceById != null) {
      _chatWebSocketServiceById!.onNewMessage((data) {
        print('Новое сообщение для chatId $chatId: $data');
        if (!_messagesByChatId.containsKey(chatId)) {
          _messagesByChatId[chatId] = [];
        }
        _messagesByChatId[chatId]!.add(data);
        notifyListeners();
      });
      _chatWebSocketServiceById!.sendMessage('{"event": "get_chat_messages"}');
    }
  }
}
