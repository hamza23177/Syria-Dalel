import 'package:dio/dio.dart';
import '../local/category_cache.dart';
import '../models/category_model.dart';
import '../constant.dart';

class CategoryService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10), // مهم جداً
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<CategoryResponse> fetchCategories({int page = 1, int perPage = 1000}) async {
    try {
      final response = await dio.get(
        '/user/categories',
        queryParameters: {
          'page': page,
          'perPage': perPage, // 🔥 السحر هنا: نطلب كل شيء
        },
      );

      if (response.statusCode == 200) {
        return CategoryResponse.fromJson(response.data);
      } else {
        throw Exception("فشل تحميل البيانات: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception("لا يوجد اتصال بالإنترنت");
      }
      throw Exception("خطأ في الاتصال بالخادم");
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع: $e");
    }
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
