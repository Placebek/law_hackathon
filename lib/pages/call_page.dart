import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallPage extends StatelessWidget {
  // Пример номера сотрудника полиции (замените на реальный, если есть)
  final String policePhoneNumber = 'tel:+77001234567';

  Future<void> _makeCall(BuildContext context) async {
    if (await canLaunch(policePhoneNumber)) {
      await launch(policePhoneNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось совершить звонок')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Звонок сотруднику полиции',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone,
              size: 80,
              color: Color(0xFF1E88E5),
            ),
            SizedBox(height: 20),
            Text(
              'Вызов сотрудника полиции',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Нажмите, чтобы позвонить',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _makeCall(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Позвонить',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
