import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новости')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(title: Text('Новость 1')),
          ListTile(title: Text('Новость 2')),
          ListTile(title: Text('Новость 3')),
        ],
      ),
    );
  }
}
