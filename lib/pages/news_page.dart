import 'package:flutter/material.dart';
import '../api/mock_news.dart';
import '../api/models/news_models.dart';
import 'news_detail_page.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<News>> futureNews;

  @override
  void initState() {
    super.initState();
    futureNews =
        Future.value(MockNews.getMockNews()); // Используем моковые данные
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новости')),
      body: FutureBuilder<List<News>>(
        future: futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Новостей нет'));
          }

          List<News> newsList = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              News news = newsList[index];
              return ListTile(
                title: Text(news.text),
                subtitle: Text(news.date),
                leading: Image.network(news.image,
                    width: 50, height: 50, fit: BoxFit.cover),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(newsId: news.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
