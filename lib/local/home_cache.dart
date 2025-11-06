// data/local/home_cache.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/home_model.dart';

class HomeCache {
  static const String _cacheKey = 'cached_home_data';

  /// حفظ بيانات الصفحة
  Future<void> saveHomeData(HomeData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(_cacheKey, jsonString);
  }

  /// استرجاع البيانات المخزنة
  Future<HomeData?> getCachedHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return null;
    try {
      final jsonMap = jsonDecode(jsonString);
      return HomeData.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  /// حذف الكاش عند الحاجة
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
