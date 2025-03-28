import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_page.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Главная')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                const url = 'tel:102';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Не удалось позвонить')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Цвет фона кнопки
                  padding: EdgeInsets.all(40),
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Colors.white, // Цвет границы
                      width: 4, // Ширина границы
                    ),
                  )),
              child: Text(
                '102',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
                // Устанавливаем белый цвет текста
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Экстренное сообщение отправлено')),
                );
              },
              child: Text(
                'Отправить сигнал тревоги',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage()),
                );
              },
              child: Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_map.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Нажми для карты',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
