import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api/auth_service.dart';
import '../services/websocket/police_websocket_service.dart';
import '../services/websocket/chat_websocket_service.dart';
import '../services/websocket/chat_messages_websocket_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _verificationToken;
  final AuthService _authService = AuthService();
  PoliceWebSocketService? _policeWebSocketService;
  ChatWebSocketService? _chatWebSocketService;
  ChatMessagesWebSocketService? _chatMessagesWebSocketService;

  bool get isAuthenticated => _token != null;
  String? get username => _username;
  String? get token => _token;
  PoliceWebSocketService? get policeWebSocketService => _policeWebSocketService;
  ChatWebSocketService? get chatWebSocketService => _chatWebSocketService;
  ChatMessagesWebSocketService? get chatMessagesWebSocketService =>
      _chatMessagesWebSocketService;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _username = prefs.getString('username');
    if (_token != null) {
      _initializeWebSocket(_token!);
    }
    notifyListeners();
  }

  Future<String> sendVerification(String email) async {
    try {
      final response = await _authService.sendVerification(email);
      _verificationToken = response['access_token'];
      _username = email;
      return response['message'];
    } catch (e) {
      throw Exception('Ошибка отправки кода: $e');
    }
  }

  Future<void> verifyCode(String code) async {
    if (_verificationToken == null) {
      throw Exception('Токен верификации отсутствует');
    }
    try {
      final response = await _authService.verifyCode(_verificationToken!, code);
      _token = response['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('username', _username!);
      _initializeWebSocket(_token!);
      _verificationToken = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка верификации: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _verificationToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
    _policeWebSocketService?.disconnect();
    _chatWebSocketService?.disconnect();
    _chatMessagesWebSocketService?.disconnect();
    _policeWebSocketService = null;
    _chatWebSocketService = null;
    _chatMessagesWebSocketService = null;
    notifyListeners();
  }

  void _initializeWebSocket(String token) {
    _policeWebSocketService = PoliceWebSocketService(token);
    _chatWebSocketService = ChatWebSocketService(token);
    _chatWebSocketService!.authenticate(token);
    // _chatMessagesWebSocketService будет инициализирован позже с конкретным chat_id
  }

  void initializeChatMessagesWebSocket(String token, int chatId) {
    _chatMessagesWebSocketService = ChatMessagesWebSocketService(token, chatId);
  }
}
