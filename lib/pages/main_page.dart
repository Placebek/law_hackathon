import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map_page.dart';
import 'chat_page.dart';
import 'call_page.dart';
import '../emergency_button.dart';
import 'statement_page.dart';
import 'accident_page.dart';
import '../api/token_manager.dart';

void main() {
  runApp(
    MaterialApp(
      home: MainPage(),
    ),
  );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? _residentAddress;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndData(); // Единственный вызов для загрузки токена и адреса
  }

  Future<void> _loadTokenAndData() async {
    _token = await TokenManager.getToken();
    await _getResidentLocationAndAddress();
    setState(() {}); // Обновляем UI после загрузки данных
  }

  Future<void> _getResidentLocationAndAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _residentAddress = "Геолокация отключена");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _residentAddress = "Разрешение отклонено");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _residentAddress = "Геолокация недоступна");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      const String apiKey = 'AIzaSyBSbxEMIihoDxq906w9DMp6XWgwmW1iHgQ';
      String url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'].isNotEmpty) {
          setState(() {
            _residentAddress = data['results'][0]['formatted_address'];
          });
        } else {
          setState(() => _residentAddress = "г. Караганда, ул. Алалыкина 12");
        }
      } else {
        setState(() => _residentAddress = "г. Караганда, ул. Алалыкина 12");
      }
    } catch (e) {
      setState(() => _residentAddress = "г. Караганда, ул. Алалыкина 12");
    }
  }

  void _showStatementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatementPage(),
        ),
      ),
    );
  }

  void _showAccidentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AccidentPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Qamqor Life',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Flexible(
                child: Text(
                  _residentAddress ?? 'Получение адреса...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EmergencyButton(),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          context: context,
                          icon: Icons.chat_bubble_outline,
                          label: 'Чат',
                          gradientColors: [
                            Color(0xFF1E88E5),
                            Color(0xFF42A5F5)
                          ],
                          onTap: () {
                            if (_token != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatPage(token: _token!),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Токен отсутствует. Пожалуйста, войдите'),
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(width: 20),
                        _buildActionButton(
                          context: context,
                          icon: Icons.phone_outlined,
                          label: 'Звонок',
                          gradientColors: [
                            Color(0xFF4CAF50),
                            Color(0xFF81C784)
                          ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CallPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapPage()),
                        );
                      },
                      child: Container(
                        height: 120,
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage('assets/images/mini_map.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'На карте',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _showStatementSheet,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF1E88E5), width: 2),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF1E88E5),
                      elevation: 2,
                      shadowColor: Colors.grey.withOpacity(0.3),
                    ),
                    child: Text(
                      'Заявление',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _showAccidentSheet,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF4CAF50), width: 2),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF4CAF50),
                      elevation: 2,
                      shadowColor: Colors.grey.withOpacity(0.3),
                    ),
                    child: Text(
                      'Происшествие',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.5),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
