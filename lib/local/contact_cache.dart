import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';

class ContactCache {
  static const _key = 'cached_contact_info';

  /// 🧠 حفظ بيانات التواصل في الكاش
  static Future<void> saveContact(ContactModel contact) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(contact.toJson());
    await prefs.setString(_key, jsonData);
  }

  /// 🔍 جلب بيانات التواصل من الكاش
  static Future<ContactModel?> getCachedContact() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    try {
      final data = jsonDecode(jsonString);
      return ContactModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// 🗑️ مسح الكاش
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
