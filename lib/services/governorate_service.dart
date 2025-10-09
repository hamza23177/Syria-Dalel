// governorate_service.dart
import 'package:dio/dio.dart';
import '../models/governorate_model.dart';
import '../constant.dart';

class GovernorateService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<List<Governorate>> getGovernorates({int perPage = 20}) async {
    final response = await dio.get('/user/governorates?perPage=$perPage');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => Governorate.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load governorates');
    }
  }
}

