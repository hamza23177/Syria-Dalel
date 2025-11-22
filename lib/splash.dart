import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled2/constant.dart';
import 'package:untitled2/screens/main_screen.dart';
import '../services/notification_service.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  // Animations
  late AnimationController _mainController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // مدة العرض الكاملة
    );

    // تأثير الظهور
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    // تأثير الانزلاق للأعلى
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );

    // تأثير النبض الخفيف (Scale)
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 1.0, curve: Curves.elasticOut)),
    );

    _mainController.forward();

    // بدء عملية التهيئة والانتقال
    _initializeApp();
  }

  /// ⚙️ دالة تجمع بين وقت الأنيميشن وتهيئة البيانات
  Future<void> _initializeApp() async {
    // 1. ننتظر انتهاء الأنيميشن كحد أدنى (لجمالية التطبيق)
    // 2. نقوم بأي تهيئة ثقيلة هنا (مثل جلب بيانات المستخدم، توكن، الخ)

    final minWait = Future.delayed(const Duration(seconds: 3));

    // مثال: إذا كنت تريد إرسال إشعار ترحيبي فقط عند أول تثبيت (يمكن تخزين flag في shared_preferences)
    // await NotificationService.showImmediateNotification(...);

    await minWait; // ننتظر انتهاء الوقت

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PersistentBtmBarExample(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // انتقال ناعم (Fade) للصفحة الرئيسية
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // أو AppColors.background
      body: Stack(
        children: [
          // خلفية زخرفية خفيفة (اختياري)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),

          // المحتوى الرئيسي في الوسط
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _slideAnimation.value * 100, // تحريك بسيط
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Image.asset(
                              'assets/Icon.png', // تأكد أن الأيقونة مفرغة (PNG)
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // اسم التطبيق بظهور متأخر قليلاً
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Column(
                    children: [
                      Text(
                        "دليل سوريا",
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "كل الخدمات بين يديك",
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 14,
                          color: AppColors.textLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // الحقوق والإصدار في الأسفل
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "الإصدار 1.0.0",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}