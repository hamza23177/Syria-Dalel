import 'package:dio/dio.dart';
import '../models/contact_model.dart';
import '../constant.dart';

class ContactApi {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<ContactModel> fetchContactInfo() async {
    try {
      final response = await dio.get("/contact");

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ContactModel.fromJson(response.data['data']);
      } else {
        throw Exception("فشل جلب بيانات التواصل");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال بالخادم: $e");
    }
  }
}
