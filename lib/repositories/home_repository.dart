// data/repositories/home_repository.dart
import '../services/home_service.dart';
import '../local/home_cache.dart';
import '../models/home_model.dart';
import 'dart:io';

class HomeRepository {
  final HomeService service;
  final HomeCache cache;

  HomeRepository({required this.service, required this.cache});

  /// تحميل البيانات من الإنترنت أو من الكاش
  Future<HomeData> getHomeData({int page = 1, int perPage = 10}) async {
    // جلب الكاش أولًا
    final cached = await cache.getCachedHomeData();

    try {
      final data = await service.fetchHomeData(page: page, perPage: perPage);
      if (page == 1) await cache.saveHomeData(data);
      return data;
    } on SocketException {
      if (cached != null) {
        return cached; // عرض الكاش عند عدم وجود الإنترنت
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت ولا بيانات مخزنة.');
      }
    } catch (e) {
      if (cached != null) return cached;
      rethrow;
    }
  }

}
