import 'package:dio/dio.dart';
import '../local/category_cache.dart';
import '../models/category_model.dart';
import '../constant.dart';

class CategoryService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<CategoryResponse> fetchCategories({required int page, int perPage = 10}) async {
    // 🟢 جرب جلب الكاش أولاً
    if (page == 1) {
      final cached = await CategoryCacheService.getCachedCategories();
      if (cached != null && cached.data.isNotEmpty) {
        // ✅ ارجع الكاش بسرعة قبل انتظار الإنترنت
        _updateInBackground(page, perPage);
        return cached;
      }
    }

    // 🟡 إذا لا يوجد كاش، نفذ الطلب عادي
    return await _fetchFromNetwork(page, perPage);
  }

  Future<void> _updateInBackground(int page, int perPage) async {
    try {
      final fresh = await _fetchFromNetwork(page, perPage);
      await CategoryCacheService.saveCategories(fresh);
    } catch (_) {
      // تجاهل الأخطاء في الخلفية
    }
  }

  Future<CategoryResponse> _fetchFromNetwork(int page, int perPage) async {
    try {
      final response = await dio.get(
        '/user/categories',
        queryParameters: {'page': page, 'perPage': perPage},
      );

      if (response.statusCode == 200) {
        final result = CategoryResponse.fromJson(response.data);
        if (page == 1) await CategoryCacheService.saveCategories(result);
        return result;
      } else {
        throw Exception("فشل في تحميل البيانات (${response.statusMessage})");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception("انتهت مهلة الاتصال بالخادم.");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("لا يوجد اتصال بالإنترنت.");
      } else {
        throw Exception("خطأ من الخادم (${e.response?.statusCode})");
      }
    } catch (e) {
      throw Exception("حدث خطأ أثناء تحميل الأقسام: $e");
    }
  }
}
