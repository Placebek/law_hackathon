import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String name;
  User(this.name);
}

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;

  bool get isAuthenticated => _token != null;
  User? get user => _user;

  AuthProvider() {
    _loadToken(); // Проверка токена при запуске
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _user = User(prefs.getString('user_name') ?? 'User');
    }
    notifyListeners();
  }

  Future<void> setToken(String token, String name) async {
    final prefs = await SharedPreferences.getInstance();
    _token = token;
    _user =
        User(name); // Используем email как имя, можно заменить на данные из API
    await prefs.setString('auth_token', token);
    await prefs.setString('user_name', name);
    notifyListeners(); // Обновляем UI
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    _token = null;
    _user = null;
    notifyListeners();
  }
}
