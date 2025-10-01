import 'package:dio/dio.dart';
import '../models/category_model.dart';

class CategoryService {
  final Dio dio = Dio();
  final String baseUrl = "http://10.184.121.64:8000/api/user/categories";

  Future<CategoryResponse> fetchCategories({int page = 1, int perPage = 20}) async {
    final response = await dio.get("$baseUrl?page=$page&perPage=$perPage");

    if (response.statusCode == 200) {
      return CategoryResponse.fromJson(response.data);
    } else {
      throw Exception("فشل جلب البيانات: ${response.statusMessage}");
    }
  }

}
