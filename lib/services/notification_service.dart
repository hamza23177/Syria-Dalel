import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);
  }

  static Future<void> showRandomMotivation() async {
    final List<String> messages = [
      'شو رأيك تشوف الخدمات الجديدة اليوم؟ 👀',
      'ضيف خدمتك وخلّي الناس تشوفك 💪',
      'في خدمات جديدة بمنطقتك، شوفها الآن!',
      'ما بدك تكون أول من يكتشف الجديد؟ 😉',
      'دليل سوريا بيكبر كل يوم، خليك معنا 🌟',
    ];

    final random = Random();
    final message = messages[random.nextInt(messages.length)];

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'motivation_channel',
      'تحفيز المستخدمين',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      random.nextInt(10000),
      'دليل سوريا 🇸🇾',
      message,
      details,
    );
  }
}
