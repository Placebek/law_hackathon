import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api/auth_service.dart';
import '../services/websocket/websocket_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _verificationToken;
  final AuthService _authService = AuthService();
  final WebSocketService _webSocketService = WebSocketService();

  bool get isAuthenticated => _token != null;
  String? get username => _username;
  String? get token => _token;
  WebSocketService get webSocketService => _webSocketService;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _username = prefs.getString('username');
    if (_token != null) {
      _webSocketService.authenticate(_token!);
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
    if (_verificationToken == null)
      throw Exception('Токен верификации отсутствует');
    try {
      final response = await _authService.verifyCode(_verificationToken!, code);
      _token = response['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('username', _username!);
      _webSocketService.authenticate(_token!);
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
    _webSocketService.disconnect();
    notifyListeners();
  }
}
