import 'dart:math';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings('logo');

  void initializeNotifications() async {
    InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification(
    String title,
    String body,
  ) async {
    Random random = Random();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
            'schedule_channel_0001', 'schedule_task',
            importance: Importance.max, priority: Priority.high);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        random.nextInt(1000000) + 1, title, body, notificationDetails);
  }

  void scheduleNotification(String title, String body, DateTime time) async {
    Random random = Random();
    tz.TZDateTime dateTime = tz.TZDateTime.from(time, tz.local);
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'schedule_channel_0001',
      'schedule_task',
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
        random.nextInt(100000) + 1, title, body, dateTime, notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}

