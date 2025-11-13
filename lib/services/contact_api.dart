import 'package:dio/dio.dart';
import '../models/contact_model.dart';
import '../constant.dart';
import '../local/contact_cache.dart';

class ContactApi {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<ContactModel> fetchContactInfo() async {
    try {
      final response = await dio.get("/contact");

      if (response.statusCode == 200 && response.data['status'] == true) {
        final contact = ContactModel.fromJson(response.data['data']);
        // 🧠 حفظ البيانات في الكاش بعد كل نجاح
        await ContactCache.saveContact(contact);
        return contact;
      } else {
        throw Exception("حدث خطأ أثناء جلب بيانات التواصل من الخادم");
      }
    } on DioException catch (e) {
      // ✅ عند انقطاع الإنترنت نحاول جلب البيانات من الكاش
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        final cached = await ContactCache.getCachedContact();
        if (cached != null) {
          return cached;
        } else {
          throw Exception("لا يوجد اتصال بالإنترنت، ولا توجد بيانات محفوظة.");
        }
      } else {
        throw Exception("حدث خطأ أثناء الاتصال بالخادم (${e.message}).");
      }
    } catch (e) {
      // ✅ جلب من الكاش في حال أي خطأ آخر
      final cached = await ContactCache.getCachedContact();
      if (cached != null) {
        return cached;
      }
      throw Exception("حدث خطأ غير متوقع أثناء الاتصال بالخادم.");
    }
  }
}
