import 'package:dio/dio.dart';
import '../models/home_model.dart';

class HomeService {
  final Dio dio = Dio();

  Future<HomeData> fetchHomeData({int perPage = 10}) async {
    final response = await dio.get(
      'http://10.184.121.64:8000/api/user/home',
      queryParameters: {'perPage': perPage},
    );

    if (response.statusCode == 200) {
      return HomeData.fromJson(response.data);
    } else {
      throw Exception('Failed to load home data');
    }
  }
}
