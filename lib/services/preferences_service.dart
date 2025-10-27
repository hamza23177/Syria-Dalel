import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyGovernorate = 'selected_governorate';
  static const _keyArea = 'selected_area';

  /// 🧠 حفظ المحافظة والمنطقة
  static Future<void> saveLocation({
    required String governorate,
    required String area,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGovernorate, governorate);
    await prefs.setString(_keyArea, area);
  }

  /// 📦 جلب القيم المحفوظة
  static Future<Map<String, String?>> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final governorate = prefs.getString(_keyGovernorate);
    final area = prefs.getString(_keyArea);
    return {
      'governorate': governorate,
      'area': area,
    };
  }

  /// 🧹 مسح القيم (عند تسجيل الخروج مثلًا)
  static Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGovernorate);
    await prefs.remove(_keyArea);
  }
}
