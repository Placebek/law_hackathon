import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({super.key});

  Future<void> _makeEmergencyCall(BuildContext context) async {
    const String number = '102';
    try {
      bool? callSuccess = await FlutterPhoneDirectCaller.callNumber(number);
      if (callSuccess != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось выполнить звонок на 102')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _makeEmergencyCall(context),
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: Text(
            '102',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
