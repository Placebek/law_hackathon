import './models/news_models.dart';

class MockNews {
  static List<News> getMockNews() {
    return [
      News(
        id: 1,
        text: "В Казахстане открыли новый IT-хаб",
        date: "2025-03-29",
        image: "https://via.placeholder.com/150",
      ),
      News(
        id: 2,
        text: "В Алматы прошел международный хакатон",
        date: "2025-03-28",
        image: "https://via.placeholder.com/150",
      ),
      News(
        id: 3,
        text: "Новый закон о цифровой безопасности вступил в силу",
        date: "2025-03-27",
        image: "https://via.placeholder.com/150",
      ),
      News(
        id: 4,
        text: "Казахстанские разработчики создали инновационный AI-продукт",
        date: "2025-03-26",
        image: "https://via.placeholder.com/150",
      ),
      News(
        id: 5,
        text: "5G интернет теперь доступен в крупных городах страны",
        date: "2025-03-25",
        image: "https://via.placeholder.com/150",
      ),
    ];
  }
}
