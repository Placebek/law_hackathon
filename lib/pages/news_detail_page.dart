import 'package:flutter/material.dart';
import '../api/news_api.dart';
import '../api/models/news_models.dart';

class NewsDetailPage extends StatelessWidget {
  final int newsId;

  NewsDetailPage({required this.newsId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Детали новости')),
      body: FutureBuilder<News>(
        future: NewsApi.fetchNewsById(newsId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Новость не найдена'));
          }

          News news = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                news.image.isNotEmpty
                    ? Image.network(news.image)
                    : SizedBox.shrink(),
                SizedBox(height: 16),
                Text(news.text, style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text(news.date, style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
