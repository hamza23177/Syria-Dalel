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
        throw Exception("حدث خطأ أثناء جلب بيانات التواصل من الخادم");
      }
    } on DioException catch (e) {
      // 🧠 تحديد نوع الخطأ
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        throw Exception("لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.");
      } else if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception("انتهت مهلة الاتصال بالخادم. حاول مجددًا بعد قليل.");
      } else if (e.response != null) {
        throw Exception("حدث خطأ في الخادم (${e.response?.statusCode}).");
      } else {
        throw Exception("حدث خطأ غير متوقع. حاول مرة أخرى.");
      }
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع أثناء الاتصال بالخادم.");
    }
  }
}
