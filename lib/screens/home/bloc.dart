import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/home_repository.dart';
import 'event.dart';
import 'state.dart';
import '../../services/home_service.dart';
import '../../models/home_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  HomeData? cachedData;

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<LoadMoreHomeData>(_onLoadMoreHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event,
      Emitter<HomeState> emit,
      ) async {
    if (isLoading) return;
    isLoading = true;

    emit(HomeLoading());

    try {
      // ⚡ عرض الكاش فورا إن وجد
      final cached = await repository.cache.getCachedHomeData();
      if (cached != null) {
        cachedData = cached;
        emit(HomeLoaded(cached, isLoadingMore: false, reachedEnd: false));
      }

      // تحميل الصفحة الأولى
      currentPage = 1;
      final data = await repository.getHomeData(page: 1, perPage: event.perPage);

      cachedData = data;

      // إذا أقل من perPage إذن هذا آخر Page
      hasMore = data.products.length == event.perPage;

      emit(HomeLoaded(data, isLoadingMore: false, reachedEnd: !hasMore));
    } catch (e) {
      if (cachedData == null) emit(HomeError("حدث خطأ أثناء التحميل"));
    }

    isLoading = false;
  }


  Future<void> _onLoadMoreHomeData(
      LoadMoreHomeData event,
      Emitter<HomeState> emit,
      ) async {
    if (isLoading || !hasMore) return;
    if (cachedData == null) return;

    isLoading = true;

    // ⭐ Debounce آمن داخل async
    await Future.delayed(const Duration(milliseconds: 200));

    emit(HomeLoaded(cachedData!, isLoadingMore: true));

    try {
      currentPage++;

      final newData = await repository.getHomeData(
        page: currentPage,
        perPage: event.perPage,
      );

      cachedData!.products.addAll(newData.products);
      cachedData!.categories.addAll(newData.categories);
      cachedData!.subCategories.addAll(newData.subCategories);

      if (newData.products.length < event.perPage) {
        hasMore = false;
      }

      emit(
        HomeLoaded(
          cachedData!,
          isLoadingMore: false,
          reachedEnd: !hasMore,
        ),
      );
    } catch (_) {
      emit(
        HomeLoaded(
          cachedData!,
          isLoadingMore: false,
          reachedEnd: !hasMore,
        ),
      );
    }

    isLoading = false;
  }




  String _handleDioError(DioError e) {
    if (e.type == DioErrorType.connectionTimeout ||
        e.type == DioErrorType.receiveTimeout) {
      return "انتهت مهلة الاتصال. تحقق من الإنترنت.";
    } else if (e.type == DioErrorType.badResponse) {
      final status = e.response?.statusCode ?? 0;
      if (status >= 500) {
        return "حدث خطأ في الخادم.";
      } else {
        return e.response?.data["message"] ?? "خطأ غير متوقع.";
      }
    } else if (e.error is SocketException) {
      return "لا يوجد اتصال بالإنترنت.";
    }
    return "تعذر تحميل البيانات.";
  }
}
