import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    await _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      print("Permission granted for notifications.");
    } else {
      print("Permission denied for notifications.");
    }
  }

  /// 📌 Исправленный метод, теперь принимает `id`, `title`, `body`
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    print("Attempting to show notification...");

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_priority_channel', // Уникальный ID канала
      'High Priority Notifications', // Название канала
      channelDescription:
          'This channel is used for high priority notifications.', // Описание канала
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false, // Отключаем отображение времени
      playSound: true, // Включаем звук
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title, // Теперь можно передавать заголовок
        body, // Теперь можно передавать текст сообщения
        platformChannelSpecifics,
        payload: 'Custom Payload',
      );
      print("Notification displayed successfully!");
    } catch (e) {
      print("Error displaying notification: $e");
    }
  }

  /// Обработка нажатия на уведомление
  Future<void> onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    String? payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification payload: $payload');
      // Здесь можно обработать переход к экрану или другие действия при нажатии
    }
  }
}
