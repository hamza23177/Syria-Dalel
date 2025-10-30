import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../services/home_service.dart';
import '../../models/home_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService service;
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  HomeData? cachedData;

  Timer? _throttleTimer;

  HomeBloc(this.service) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<LoadMoreHomeData>(_onLoadMoreData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      currentPage = 1;
      hasMore = true;
      final data =
      await service.fetchHomeData(page: currentPage, perPage: event.perPage);
      cachedData = data;
      emit(HomeLoaded(data, isLoadingMore: false));
    } on DioError catch (e) {
      emit(HomeError(_handleDioError(e)));
    } catch (e) {
      emit(HomeError("حدث خطأ غير متوقع: ${e.toString()}"));
    }
  }

  Future<void> _onLoadMoreData(
      LoadMoreHomeData event, Emitter<HomeState> emit) async {
    if (isLoadingMore || !hasMore) return;

    // 🚫 لا تكمل لو لم يتم تحميل الصفحة الأولى بعد
    if (cachedData == null) return;

    // Throttle لمنع التحميل المكرر السريع
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(const Duration(milliseconds: 400), () {});

    isLoadingMore = true;
    emit(HomeLoaded(cachedData!, isLoadingMore: true));

    try {
      currentPage++;
      final data =
      await service.fetchHomeData(page: currentPage, perPage: event.perPage);

      if (data.products.isEmpty &&
          data.categories.isEmpty &&
          data.subCategories.isEmpty) {
        hasMore = false;
      } else {
        cachedData!.products.addAll(data.products);
        cachedData!.categories.addAll(data.categories);
        cachedData!.subCategories.addAll(data.subCategories);
      }

      emit(HomeLoaded(cachedData!, isLoadingMore: false, reachedEnd: !hasMore));
    } on DioError catch (e) {
      emit(HomeError(_handleDioError(e)));
    } catch (e) {
      emit(HomeError("حدث خطأ غير متوقع: ${e.toString()}"));
    }

    isLoadingMore = false;
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
