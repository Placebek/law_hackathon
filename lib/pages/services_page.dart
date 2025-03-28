import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Услуги')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(title: Text('Вызов полиции')),
          ListTile(title: Text('Консультация')),
          ListTile(title: Text('Подача заявления')),
        ],
      ),
    );
  }
}
