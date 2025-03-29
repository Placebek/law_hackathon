import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: QamqorPoliceApp(),
    ),
  );
}

class QamqorPoliceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qamqor Police',
      theme: ThemeData(
        primaryColor: Color(0xFF1E88E5),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
