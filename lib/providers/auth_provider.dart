import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../websocket/websocket_service.dart';

class User {
  final String name;
  User(this.name);
}

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  WebSocketService? _webSocketService;

  bool get isAuthenticated => _token != null;
  User? get user => _user;
  WebSocketService? get webSocketService => _webSocketService;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _user = User(prefs.getString('user_name') ?? 'User');
      _initializeWebSocket();
    }
    notifyListeners();
  }

  Future<void> setToken(String token, String name) async {
    final prefs = await SharedPreferences.getInstance();
    _token = token;
    _user = User(name);
    await prefs.setString('auth_token', token);
    await prefs.setString('user_name', name);
    _initializeWebSocket();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    _token = null;
    _user = null;
    _webSocketService?.dispose();
    _webSocketService = null;
    notifyListeners();
  }

  void _initializeWebSocket() {
    if (_token != null && _webSocketService == null) {
      _webSocketService = WebSocketService(_token!);
    }
  }
}
