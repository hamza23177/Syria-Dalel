import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../constant.dart';

class CategoryService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<CategoryResponse> fetchCategories({
    required int page,
    int perPage = 10,
  }) async {
    try {
      final response = await dio.get(
        '/user/categories',
        queryParameters: {'page': page, 'perPage': perPage},
      );

      if (response.statusCode == 200) {
        return CategoryResponse.fromJson(response.data);
      } else {
        throw Exception("⚠️ فشل في تحميل البيانات من الخادم (${response.statusMessage})");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("⏱️ انتهت مهلة الاتصال بالخادم، يرجى المحاولة لاحقًا.");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("📶 لا يوجد اتصال بالإنترنت. تأكد من الاتصال وحاول مجددًا.");
      } else if (e.response != null) {
        throw Exception("🚫 خطأ من الخادم (${e.response?.statusCode}): ${e.response?.statusMessage}");
      } else {
        throw Exception("❗ حدث خطأ غير متوقع أثناء الاتصال بالخادم.");
      }
    } catch (e) {
      throw Exception("حدث خطأ أثناء تحميل الأقسام: $e");
    }
  }
}
