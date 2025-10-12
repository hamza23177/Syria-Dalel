import 'package:dio/dio.dart';
import '../../models/service_model.dart';
import '../constant.dart';

class ServiceApi {
  final Dio dio = Dio(BaseOptions(baseUrl: "${ApiConstants.baseUrl}/user"));

  Future<List<ServiceModel>> fetchServices({
    int perPage = 10,
    String? name,
    int? subCategoryId,
  }) async {
    final response = await dio.get(
      "/product",
      queryParameters: {
        "perPage": perPage,
        "name": name ?? "",
        "sub_category_id": subCategoryId,
      },
    );

    final List data = response.data['data'];
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<ServiceModel> fetchServiceDetails(int id) async {
    final response = await dio.get("/product/$id");

    if (response.statusCode == 200) {
      final data = response.data['data']; // ✅ استخراج الـ data الحقيقي
      return ServiceModel.fromJson(data);
    } else {
      throw Exception("فشل جلب تفاصيل الخدمة");
    }
  }
}
