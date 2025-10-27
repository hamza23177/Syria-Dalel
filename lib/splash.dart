import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled2/screens/main_screen.dart';
import '../services/notification_service.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _initAnimations();

    // --- الإشعارات ---
    _initNotifications();

    // الانتقال بعد 3.5 ثانية
    Timer(Duration(milliseconds: 3500), () {
      // TODO: استبدل PersistentBtmBarExample بالشاشة الرئيسية الفعلية
       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PersistentBtmBarExample()));
    });
  }

  void _initAnimations() {
    _scaleController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
    _scaleController.repeat(reverse: true);

    _slideController = AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    _slideController.forward();

    _glowController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _glowAnimation = Tween<double>(begin: 0.0, end: 25.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _glowController.repeat(reverse: true);
  }

  void _initNotifications() async {
    await NotificationService.showImmediateNotification(
      title: 'مرحباً بك في دليل سوريا 🇸🇾',
      body: 'ابدأ رحلتك لاكتشاف أفضل الخدمات والعروض في سوريا اليوم!',
      payload: 'welcome',
    );

    // تشغيل إشعار يومي واحد
    await NotificationService.scheduleDailyNotificationTask();
  }



  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset('assets/Icon.png', width: 80, height: 80),
          ),
        ),
      ),
    );
  }
}
