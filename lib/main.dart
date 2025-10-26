import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache.maximumSize = 200; // كاش أكبر
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 100; // 100MB

  // --- تهيئة Workmanager ---
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // --- تهيئة الإشعارات ---
  await NotificationService.init();

  // --- تهيئة المنطقة الزمنية ---
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Damascus'));

  runApp(const MyApp());
}

// --- @pragma مهم جدًا لـ Workmanager ---
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc(HomeService())),
        BlocProvider(create: (_) => CategoryBloc(CategoryService())),
        BlocProvider(create: (_) => SubCategoryBloc(SubCategoryService())),
        BlocProvider(create: (_) => ServiceBloc(ServiceApi() as ServiceRepository)),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
