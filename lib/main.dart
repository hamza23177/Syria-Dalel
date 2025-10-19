import 'package:flutter/material.dart';
import 'package:untitled2/screens/category/view.dart';
import 'package:untitled2/screens/contact/view.dart';
import 'package:untitled2/screens/main_screen.dart';
import 'package:untitled2/splash.dart';
import 'package:untitled2/constant.dart';
import 'package:untitled2/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- هنا نعلّم callbackDispatcher ---
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // تهيئة الإشعارات
  await NotificationService.init();

  runApp(const MyApp());
}

// @pragma('vm:entry-point') مهم جدًا!!
@pragma('vm:entry-point')

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.showImmediateNotification(
      title: inputData?['title'] ?? '📢 إشعار',
      body: inputData?['body'] ?? 'تم إرسال الإشعار',
      payload: inputData?['payload'] ?? '',
    );
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "دليل سوريا",
      routes: {
        '/categories': (_) => CategoriesScreen(),
        '/contact': (_) => ContactView(),
      },
      theme: ThemeData(
        fontFamily: AppFonts.primaryFont,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
      ),
      home: Splash(),
    );
  }
}

