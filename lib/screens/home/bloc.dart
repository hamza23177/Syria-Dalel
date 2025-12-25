// import 'dart:async';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../repositories/home_repository.dart';
// import 'event.dart';
// import 'state.dart';
// import '../../services/home_service.dart';
// import '../../models/home_model.dart';
//
// class HomeBloc extends Bloc<HomeEvent, HomeState> {
//   final HomeRepository repository;
//   int currentPage = 1;
//   bool isLoading = false;
//   bool hasMore = true;
//   HomeData? cachedData;
//
//   HomeBloc(this.repository) : super(HomeInitial()) {
//     on<LoadHomeData>(_onLoadHomeData);
//     on<LoadMoreHomeData>(_onLoadMoreHomeData);
//   }
//
//   Future<void> _onLoadHomeData(
//       LoadHomeData event,
//       Emitter<HomeState> emit,
//       ) async {
//     if (isLoading) return;
//     isLoading = true;
//
//     emit(HomeLoading());
//
//     try {
//       // ⚡ عرض الكاش فورا إن وجد (للسرعة)
//       final cached = await repository.cache.getCachedHomeData();
//       if (cached != null) {
//         cachedData = cached;
//         // 🎲 نقوم بخلط الكاش أيضاً ليعطي شعوراً بالتجدد حتى قبل جلب البيانات الجديدة
//         _randomizeData(cachedData!);
//         emit(HomeLoaded(cachedData!, isLoadingMore: false, reachedEnd: false));
//       }
//
//       // تحميل الصفحة الأولى من السيرفر
//       currentPage = 1;
//       final data = await repository.getHomeData(page: 1, perPage: event.perPage);
//
//       // 🎲🎲 هنا السحر: خلط البيانات القادمة من السيرفر فوراً
//       _randomizeData(data);
//
//       cachedData = data;
//
//       // إذا أقل من perPage إذن هذا آخر Page
//       hasMore = data.products.length == event.perPage;
//
//       emit(HomeLoaded(data, isLoadingMore: false, reachedEnd: !hasMore));
//     } catch (e) {
//       if (cachedData == null) emit(HomeError("حدث خطأ أثناء التحميل"));
//     }
//
//     isLoading = false;
//   }
//
//
//   Future<void> _onLoadMoreHomeData(
//       LoadMoreHomeData event,
//       Emitter<HomeState> emit,
//       ) async {
//     if (isLoading || !hasMore) return;
//     if (cachedData == null) return;
//
//     isLoading = true;
//
//     // ⭐ Debounce آمن
//     await Future.delayed(const Duration(milliseconds: 200));
//
//     emit(HomeLoaded(cachedData!, isLoadingMore: true));
//
//     try {
//       currentPage++;
//
//       final newData = await repository.getHomeData(
//         page: currentPage,
//         perPage: event.perPage,
//       );
//
//       // 🎲 نخلط البيانات الجديدة فقط قبل إضافتها للقائمة القديمة
//       // (هذا يحافظ على ترتيب العناصر التي رآها المستخدم في الأعلى، ويضيف التنوع في الأسفل)
//       _randomizeData(newData);
//
//       // دمج البيانات
//       // ملاحظة: لا نخلط القائمة الكاملة هنا لكي لا "تقفز" العناصر التي يشاهدها المستخدم حالياً
//       cachedData!.products.addAll(newData.products);
//
//       // بالنسبة للفئات والأقسام الفرعية، عادة لا يوجد باجينيشن لها في الـ Home
//       // ولكن لو وجد، نضيفها كما هي
//        cachedData!.categories.addAll(newData.categories);
//        cachedData!.subCategories.addAll(newData.subCategories);
//
//       if (newData.products.length < event.perPage) {
//         hasMore = false;
//       }
//
//       emit(
//         HomeLoaded(
//           cachedData!,
//           isLoadingMore: false,
//           reachedEnd: !hasMore,
//         ),
//       );
//     } catch (_) {
//       // في حال الخطأ نعيد الحالة السابقة
//       emit(
//         HomeLoaded(
//           cachedData!,
//           isLoadingMore: false,
//           reachedEnd: !hasMore,
//         ),
//       );
//     }
//
//     isLoading = false;
//   }
//
//   /// 🛠️ دالة مساعدة لخلط البيانات (Shuffle)
//   /// تجعل العرض يبدو "خارقاً" وتنافسياً
//   void _randomizeData(HomeData data) {
//     // خلط المنتجات/الخدمات
//     data.products.shuffle();
//
//     // خلط الأقسام الرئيسية (اختياري: إذا أردت تغيير ترتيب الدوائر في الأعلى)
//     data.categories.shuffle();
//
//     // خلط الأقسام الفرعية
//     data.subCategories.shuffle();
//   }
//
//   String _handleDioError(DioError e) {
//     if (e.type == DioErrorType.connectionTimeout ||
//         e.type == DioErrorType.receiveTimeout) {
//       return "انتهت مهلة الاتصال. تحقق من الإنترنت.";
//     } else if (e.type == DioErrorType.badResponse) {
//       final status = e.response?.statusCode ?? 0;
//       if (status >= 500) {
//         return "حدث خطأ في الخادم.";
//       } else {
//         return e.response?.data["message"] ?? "خطأ غير متوقع.";
//       }
//     } else if (e.error is SocketException) {
//       return "لا يوجد اتصال بالإنترنت.";
//     }
//     return "تعذر تحميل البيانات.";
//   }
// }