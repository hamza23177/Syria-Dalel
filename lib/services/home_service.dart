import 'package:dio/dio.dart';
import '../models/home_model.dart';
import '../constant.dart';

class HomeService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  /// 🔹 جلب بيانات الصفحة مع دعم الباجينيشن (page + perPage)
  Future<HomeData> fetchHomeData({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await dio.get(
        '/user/home',
        queryParameters: {
          'page': page,
          'perPage': perPage,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // في بعض السيرفرات قد تكون البيانات داخل "data"
        final jsonData = responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;

        return HomeData.fromJson(jsonData);
      } else {
        throw Exception('فشل في تحميل البيانات (${response.statusCode})');
      }
    } on DioError catch (e) {
      final message = e.response?.data?['message'] ?? e.message;
      throw Exception('خطأ في الاتصال بالسيرفر: $message');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}
