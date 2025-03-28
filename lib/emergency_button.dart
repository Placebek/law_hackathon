import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({super.key});

  Future<void> _makeEmergencyCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '102');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Не удалось выполнить звонок на 102';
    }
  }

  @override
  Widget build(BuildContext context) { 
    return ElevatedButton(
      onPressed: _makeEmergencyCall,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child:
          const Text('Экстренный вызов', style: TextStyle(color: Colors.white)),
    );
  }
}
