import 'package:flutter/material.dart';
import 'package:untitled2/splash.dart';
import 'package:untitled2/constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
          titleLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      home: Splash(),
    );

  }
}
