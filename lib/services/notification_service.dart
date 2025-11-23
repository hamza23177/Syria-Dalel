import 'dart:math';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

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
  static Future<void> init() async {
    tz.initializeTimeZones();
    // ضبط التوقيت المحلي لدمشق
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Damascus'));
    } catch (e) {
      print("Could not set location to Damascus, using default local.");
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher'); // تأكد من وجود الأيقونة
    // const iosInit = DarwinInitializationSettings(); // إذا كنت ستدعم iOS لاحقاً

    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // هنا يمكنك التعامل مع النقر على الإشعار (مثلاً فتح صفحة معينة)
        print("Clicked Payload: ${details.payload}");
      },
    );

    print('✅ NotificationService Initialized Successfully');
  }

  /// --- إظهار إشعار فوري ---
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'daily_channel_id',
      'إشعارات دليل سوريا اليومية',
      channelDescription: 'قناة مخصصة للنصائح والعروض اليومية',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body, htmlFormatBigText: true),
      color: const Color(0xffF57752), // لون التطبيق الأساسي
    );

    final details = NotificationDetails(android: androidDetails);

    // نستخدم Random ID لكي لا يستبدل الإشعار القديم إذا لم يقرأه المستخدم
    await _notifications.show(
      Random().nextInt(100000),
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

  /// --- جدولة المهمة الدورية (Workmanager) ---
  static Future<void> scheduleDailyTask() async {
    await Workmanager().cancelAll(); // تنظيف المهام القديمة لمنع التضارب

    // تسجيل مهمة دورية تعمل كل 24 ساعة
    await Workmanager().registerPeriodicTask(
      "unique_daily_marketing_task",
      "marketingTask",
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(hours: 12), // اختياري: لتبدأ في وقت محدد تقريباً
      constraints: Constraints(
        networkType: NetworkType.not_required, // يعمل حتى بدون نت (الإشعار محلي)
        requiresBatteryNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep, // الحفاظ على الجدول الزمني
    );
    print('📅 Daily Marketing Task Scheduled');
  }
}