// bloc/home/home_bloc.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../services/home_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService service;

  HomeBloc(this.service) : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        final data = await service.fetchHomeData(perPage: 10);
        emit(HomeLoaded(data));
      } on DioError catch (e) {
        String message;
        if (e.type == DioErrorType.connectionTimeout ||
            e.type == DioErrorType.receiveTimeout) {
          message = "انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مرة أخرى.";
        } else if (e.type == DioErrorType.badResponse) {
          final status = e.response?.statusCode ?? 0;
          if (status >= 500) {
            message = "حدث خطأ في الخادم. الرجاء المحاولة لاحقاً.";
          } else {
            message = e.response?.data["message"] ??
                "حدث خطأ غير متوقع من الخادم.";
          }
        } else if (e.error is SocketException) {
          message = "لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجدداً.";
        } else {
          message = "تعذر تحميل البيانات. حاول لاحقاً.";
        }
        emit(HomeError(message));
      } catch (e) {
        emit(HomeError("حدث خطأ غير متوقع: ${e.toString()}"));
      }
    });
  }
}
