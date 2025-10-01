// area_service.dart
import 'package:dio/dio.dart';
import '../models/area_model.dart';

class AreaService {
  final Dio dio = Dio();

  Future<List<Area>> getAreas({int perPage = 20}) async {
    final response = await dio.get('http://10.184.121.64:8000/api/user/areas?perPage=$perPage');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => Area.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load areas');
    }
  }
}
