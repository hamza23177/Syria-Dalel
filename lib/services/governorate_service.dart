// governorate_service.dart
import 'package:dio/dio.dart';
import '../models/governorate_model.dart';

class GovernorateService {
  final Dio dio = Dio();

  Future<List<Governorate>> getGovernorates({int perPage = 20}) async {
    final response = await dio.get('http://10.184.121.64:8000/api/user/governorates?perPage=$perPage');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => Governorate.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load governorates');
    }
  }
}

