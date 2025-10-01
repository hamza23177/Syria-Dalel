import 'package:dio/dio.dart';
import '../../models/service_model.dart';

class ServiceApi {
  final Dio dio = Dio(BaseOptions(baseUrl: "http://10.184.121.64:8000/api/user/"));

  Future<List<ServiceModel>> fetchServices({
    int perPage = 10,
    String? name,
    int? subCategoryId,
  }) async {
    final response = await dio.get(
      "product",
      queryParameters: {
        "perPage": perPage,
        "name": name ?? "",
        "sub_category_id": subCategoryId,
      },
    );

    final List data = response.data['data'];
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }
}
