import 'package:dio/dio.dart';
import '../models/home_model.dart';
import '../constant.dart';

class HomeService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<HomeData> fetchHomeData({int perPage = 10}) async {
    final response = await dio.get(
      '/user/home',
      queryParameters: {'perPage': perPage},
    );

    if (response.statusCode == 200) {
      return HomeData.fromJson(response.data);
    } else {
      throw Exception('Failed to load home data');
    }
  }
}
