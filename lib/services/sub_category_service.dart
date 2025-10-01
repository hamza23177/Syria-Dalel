
import 'package:dio/dio.dart';

import '../models/sub_category_model.dart';


class SubCategoryService {
  final Dio _dio = Dio();

  Future<SubCategoryResponse> fetchSubCategories({
    required int categoryId,
    int page = 1,
    int perPage = 10,
    String? name,
  }) async {
    final response = await _dio.get(
      'http://10.184.121.64:8000/api/user/subCategories',
      queryParameters: {
        'category_id': categoryId,
        'page': page,
        'perPage': perPage,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );

    return SubCategoryResponse.fromJson(response.data);
  }
}
