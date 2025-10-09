import 'package:dio/dio.dart';
import '../models/ad_model.dart';
import '../constant.dart';

class AdService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<List<AdModel>> fetchHomeAds() async {
    try {
      final response = await _dio.get('/ads');

      final data = response.data['data'] as List;
      return data.map((ad) => AdModel.fromJson(ad)).toList();
    } catch (e) {
      throw Exception("Failed to load ads: $e");
    }
  }
}
