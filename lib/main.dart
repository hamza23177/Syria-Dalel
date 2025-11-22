import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled2/repositories/home_repository.dart';
import 'package:untitled2/screens/category/bloc.dart';
import 'package:untitled2/screens/category/view.dart';
import 'package:untitled2/screens/contact/view.dart';
import 'package:untitled2/screens/home/bloc.dart';
import 'package:untitled2/screens/main_screen.dart';
import 'package:untitled2/screens/prod/bloc.dart';
import 'package:untitled2/screens/prod/service_repository.dart';
import 'package:untitled2/screens/sub/bloc.dart';
import 'package:untitled2/services/category_service.dart';
import 'package:untitled2/services/home_service.dart';
import 'package:untitled2/services/service_api.dart';
import 'package:untitled2/services/sub_category_service.dart';
import 'package:untitled2/splash.dart';
import 'package:untitled2/constant.dart';
import 'package:untitled2/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'local/home_cache.dart';

// --- نقطة الدخول للمهام الخلفية (يجب أن تكون Top-Level) ---
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("⚙️ Background Task Started: $task");

    // تهيئة الإشعارات داخل الخلفية لأن الـ main thread قد يكون مغلقاً
    await NotificationService.init();

    if (task == "marketingTask") {
      // إرسال الإشعار العشوائي
      await NotificationService.sendRandomMarketingNotification();
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Hive
  await Hive.initFlutter();

  // 2. تهيئة Workmanager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // اجعلها true أثناء التجريب لرؤية الإشعارات فوراً
  );

  // 3. تهيئة الإشعارات
  await NotificationService.init();

  // 4. جدولة المهمة اليومية
  await NotificationService.scheduleDailyTask();

  // تحسين أداء الصور
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 150; // 150MB

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // ... (نفس المزودات الخاصة بك) ...
      providers: [
        BlocProvider(create: (_) => HomeBloc(HomeRepository(service: HomeService(), cache: HomeCache()))),
        BlocProvider(create: (_) => CategoryBloc(CategoryService())),
        BlocProvider(create: (_) => SubCategoryBloc(SubCategoryService())),
        BlocProvider(create: (_) => ServiceBloc(ServiceRepository(ServiceApi()))), // تأكد من النوع الصحيح هنا
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // إخفاء شريط Debug
        title: "دليل سوريا",
        theme: ThemeData(
          fontFamily: AppFonts.primaryFont,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: AppColors.primary,
            secondary: AppColors.accent,
          ),
          useMaterial3: true, // استخدام Material 3 لتصميم أحدث
        ),
        home: Splash(),
      ),
    );
  }
}
