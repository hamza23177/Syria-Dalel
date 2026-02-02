import 'dart:math';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // --- 🧠 بنك الرسائل التسويقية (Marketing Message Bank) ---
  static final List<Map<String, String>> _marketingMessages = [
    {
      'title': '🚗 هل تعطلت سيارتك؟',
      'body': 'لا تقلق! تصفح قسم ميكانيك السيارات في دليل سوريا واعثر على أقرب ورشة إليك فوراً.'
    },
    {
      'title': '🍽️ محتار شو تتغدا اليوم؟',
      'body': 'اكتشف أفضل المطاعم والعروض الحصرية حولك الآن بضغطة زر.'
    },
    {
      'title': '💡 فرصة لزيادة مبيعاتك',
      'body': 'أصحاب الخدمات المميزة ينضمون إلينا يومياً. أضف خدمتك الآن وكن مثلهم!'
    },
    {
      'title': '🏠 تبحث عن منزل أحلامك؟',
      'body': 'قسم العقارات لدينا يحتوي على خيارات مميزة. ألقِ نظرة قد تجد ما تبحث عنه.'
    },
    {
      'title': '🔥 عروض لا تفوت!',
      'body': 'تجار سوريا يقدمون خصومات رائعة اليوم. تصفح التطبيق ولا تضيع الفرصة.'
    },
    {
      'title': '🩺 صحتك تهمنا',
      'body': 'دليل كامل للأطباء والمشافي والصيدليات المناوبة بالقرب منك.'
    },
    {
      'title': '👋 اشتقنا لك!',
      'body': 'لقد تمت إضافة خدمات جديدة في منطقتك. ادخل لتستكشفها.'
    },
  ];

  /// --- تهيئة الإشعارات ---
  /// --- تهيئة الإشعارات ---
  static Future<void> init({bool isBackground = false}) async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Damascus'));
    } catch (e) {
      print("Could not set location, using default.");
    }

    // إعداد أيقونة التطبيق (تأكد أن الاسم مطابق للموجود في android/app/src/main/res/drawable)
    // يفضل استخدام أيقونة شفافة صغيرة للإشعارات باسم 'notification_icon'
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // هذا الكود يعمل فقط عندما يكون التطبيق مفتوحاً أو عند الضغط على الإشعار
        print("🔔 Clicked Payload: ${details.payload}");
        // سنعالج التوجيه في main.dart
      },
    );

    // 🔥 التعديل الجوهري: نطلب الإذن فقط إذا لم نكن في الخلفية
    if (!isBackground) {
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  /// --- إظهار إشعار فوري ---
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'syria_guide_daily_channel', // ID ثابت للقناة
      'عروض وتنبيهات دليل سوريا', // اسم ظاهر للمستخدم
      channelDescription: 'إشعارات يومية تهمك',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'تنبيه من دليل سوريا',
      styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          contentTitle: title,
          htmlFormatContentTitle: true
      ),
      color: const Color(0xffF57752),
      // إضافة صوت مخصص إذا رغبت (اختياري)
      playSound: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      Random().nextInt(100000), // ID عشوائي
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// --- المنطق الذكي لإرسال إشعار عشوائي ---
  static Future<void> sendRandomMarketingNotification() async {
    final random = Random();
    final messageIndex = random.nextInt(_marketingMessages.length);
    final message = _marketingMessages[messageIndex];

    await showNotification(
      title: message['title']!,
      body: message['body']!,
      payload: 'marketing_random',
    );
  }

  /// --- جدولة المهمة ---
  static Future<void> scheduleDailyTask() async {
    await Workmanager().cancelAll(); // تنظيف القديم

    await Workmanager().registerPeriodicTask(
      "syria_guide_marketing_task_v1", // غيرنا الاسم لضمان تحديث المهمة عند المستخدمين
      "marketingTask",
      frequency: const Duration(hours: 24),
      // frequency: const Duration(minutes: 15), // 🧪 للتجربة فقط (أقل مدة مسموحة 15 دقيقة)
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.update,
    );
    print('📅 تم جدولة المهمة الدورية بنجاح');
  }
}