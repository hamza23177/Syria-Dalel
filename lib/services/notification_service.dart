import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:math';
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// --- تهيئة الإشعارات ---
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Damascus'));

    const androidInit = AndroidInitializationSettings('ic_daleel_notification');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);

    print('✅ NotificationService initialized');
  }

  /// --- إشعار فوري احترافي ---
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    String payload = '',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'إشعارات فورية',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('daleel_sound'),
      icon: 'ic_daleel_notification',
      ticker: 'دليل سوريا',
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body, htmlFormatBigText: true),
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(Random().nextInt(10000), title, body, details, payload: payload);
    print('🔔 Notification sent: $title');
  }

  /// --- إشعار بعد مدة محددة ---
  static Future<void> scheduleDelayedNotification({
    required String title,
    required String body,
    required Duration delay,
    String payload = '',
  }) async {
    Workmanager().registerOneOffTask(
      Random().nextInt(100000).toString(),
      'showNotification',
      inputData: {'title': title, 'body': body, 'payload': payload},
      initialDelay: delay,
      constraints: Constraints(networkType: NetworkType.not_required),
    );
    print('⏱️ Notification scheduled after ${delay.inSeconds} seconds');
  }

  /// --- إشعار يومي ذكي ---
  static Future<void> scheduleDailyNotification() async {
    final now = tz.TZDateTime.now(tz.local);

    // مثال: إشعار صباحي
    tz.TZDateTime morning = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 30);
    if (morning.isBefore(now)) morning = morning.add(Duration(days: 1));

    await scheduleDelayedNotification(
      title: 'صباح الخير ☀️',
      body: 'اكتشف جديد دليل سوريا اليوم! 🌟 خدمات، عروض، وأخبار مذهلة بانتظارك.',
      delay: morning.difference(now),
      payload: 'services',
    );

    // إشعار ظهر/عصر
    tz.TZDateTime noon = tz.TZDateTime(tz.local, now.year, now.month, now.day, 13, 30);
    if (noon.isBefore(now)) noon = noon.add(Duration(days: 1));

    await scheduleDelayedNotification(
      title: '🌟 تذكير بالاشتراك',
      body: 'لا تفوت الفرصة! اشترك الآن وتمتع بأحدث الخدمات والعروض اليومية.',
      delay: noon.difference(now),
      payload: 'subscribe',
    );

    // إشعار مساءً
    tz.TZDateTime evening = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18, 0);
    if (evening.isBefore(now)) evening = evening.add(Duration(days: 1));

    await scheduleDelayedNotification(
      title: '💡 نصيحة اليوم',
      body: 'استكشف خدمة جديدة في دليل سوريا وكن أول من يشارك التجربة مع أصدقائك!',
      delay: evening.difference(now),
      payload: 'services',
    );

    print('📅 Daily notifications scheduled.');
  }
}
