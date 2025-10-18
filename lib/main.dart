import 'package:flutter/material.dart';
import 'package:untitled2/splash.dart';
import 'package:untitled2/constant.dart';
import 'package:untitled2/services/notification_service.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
  startNotificationLoop(); // 🔔
}

void startNotificationLoop() {
  // إشعارات دورية محلية بدون باك
  Timer.periodic(const Duration(hours: 6), (timer) {
    NotificationService.showRandomMotivation();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "دليل سوريا",
      theme: ThemeData(
        fontFamily: AppFonts.primaryFont,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textDark, fontSize: 16),
          bodyMedium: TextStyle(color: AppColors.textLight, fontSize: 14),
          titleLarge: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      home: Splash(),
    );
  }
}
