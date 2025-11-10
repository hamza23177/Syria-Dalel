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
  bool hasMore = true;
  bool isLoadingMore = false;
  HomeData? cachedData;

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<LoadMoreHomeData>(_onLoadMoreHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      // ✅ عرض الكاش فورًا إذا موجود
      final cached = await repository.cache.getCachedHomeData();
      if (cached != null) {
        cachedData = cached;
        emit(HomeLoaded(cachedData!));
      }

      // ✅ جلب البيانات من الإنترنت لاحقًا
      currentPage = 1;
      final data =
      await repository.getHomeData(page: currentPage, perPage: event.perPage);

      cachedData = data;
      emit(HomeLoaded(data));
    } on DioError catch (e) {
      // 🔥 استخدام دالتك الاحترافية هنا
      final message = _handleDioError(e);
      if (cachedData == null) emit(HomeError(message));
    } catch (e) {
      if (cachedData == null) emit(HomeError("حدث خطأ غير متوقع."));
    }
  }

  Future<void> _onLoadMoreHomeData(
      LoadMoreHomeData event, Emitter<HomeState> emit) async {

    if (cachedData == null) return;
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    emit(HomeLoaded(cachedData!, isLoadingMore: true));

    try {
      currentPage++;
      final data =
      await repository.getHomeData(page: currentPage, perPage: event.perPage);

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
    }
    on DioError catch (e) {
      // 🔥 أيضًا نستخدمها هنا
      final message = _handleDioError(e);
      emit(HomeError(message));
    }
    catch (_) {
      emit(HomeLoaded(cachedData!, isLoadingMore: false, reachedEnd: !hasMore));
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
