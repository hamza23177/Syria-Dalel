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
        throw Exception("فشل جلب البيانات: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("خطأ في الاتصال: ${e.message}");
    }
  }
}
