import 'package:dio/dio.dart';
import '../local/sub_category_cache.dart';
import '../models/sub_category_model.dart';
import '../constant.dart';

class SubCategoryService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<SubCategoryResponse> fetchSubCategories({
    required int categoryId,
    required int page,
    int perPage = 10,
    String? name,
  }) async {
    // ✅ إذا الصفحة الأولى، جرب الكاش أولاً
    if (page == 1) {
      final cached = await SubCategoryCacheService.getCachedSubCategories(categoryId);
      if (cached != null && cached.data.isNotEmpty) {
        // 🔁 حدّث البيانات في الخلفية ولا تعطل الواجهة
        _updateInBackground(categoryId, page, perPage, name);
        return cached;
      }
    }

    // ⚡ إذا لا يوجد كاش أو صفحة إضافية، جلب مباشر من الإنترنت
    return await _fetchFromNetwork(categoryId, page, perPage, name);
  }

  Future<void> _updateInBackground(int categoryId, int page, int perPage, String? name) async {
    try {
      final fresh = await _fetchFromNetwork(categoryId, page, perPage, name);
      await SubCategoryCacheService.saveSubCategories(categoryId, fresh);
    } catch (_) {
      // تجاهل الأخطاء في التحديث الخلفي
    }
  }

  Future<SubCategoryResponse> _fetchFromNetwork(
      int categoryId,
      int page,
      int perPage,
      String? name,
      ) async {
    try {
      final response = await dio.get(
        '/user/subCategories',
        queryParameters: {
          'category_id': categoryId,
          'page': page,
          'perPage': perPage,
          if (name != null && name.isNotEmpty) 'name': name,
        },
      );

      if (response.statusCode == 200) {
        final result = SubCategoryResponse.fromJson(response.data);
        if (page == 1) await SubCategoryCacheService.saveSubCategories(categoryId, result);
        return result;
      } else {
        throw Exception("فشل في تحميل البيانات (${response.statusMessage})");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("⏱️ انتهت مهلة الاتصال بالخادم.");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("🌐 لا يوجد اتصال بالإنترنت.");
      } else {
        throw Exception("خطأ من الخادم (${e.response?.statusCode})");
      }
    } catch (e) {
      throw Exception("حدث خطأ أثناء تحميل الأقسام الفرعية: $e");
    }
  }
}
