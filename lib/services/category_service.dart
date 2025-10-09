import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../constant.dart';

class CategoryService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<CategoryResponse> fetchCategories({int page = 1, int perPage = 20}) async {
    final response = await dio.get('/user/categories?page=$page&perPage=$perPage');

    if (response.statusCode == 200) {
      return CategoryResponse.fromJson(response.data);
    } else {
      throw Exception("فشل جلب البيانات: ${response.statusMessage}");
    }
  }

}
