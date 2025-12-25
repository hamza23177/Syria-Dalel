import 'package:flutter/material.dart';

class AppColors {
  // اللون الأساسي (Brand Color) - للواجهة العلوية مثل واتساب
  static const Color primary = Color(0xffF57752);

  // الخلفية العامة
  static const Color background = Color(0xffF5F5F5);

  // الأبيض النقي - للبطاقات
  static const Color white = Color(0xffFFFFFF);

  // النصوص
  static const Color textDark = Color(0xff444444);
  static const Color textLight = Color(0xff777777);

  // لون الزر الجاذب (أضف خدمتك)
  static const Color accent = Color(0xff4CAF50);
}

class AppFonts {
  static const String primaryFont = "Cairo";
}

class ApiConstants {
  static const String baseUrl = "https://dalel-sy.ba-tech.tech/api";
}
