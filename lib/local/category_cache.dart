import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';

class CategoryCacheService {
  static const _key = 'cached_categories';

  static Future<void> saveCategories(CategoryResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(response.toJson()));
  }

  static Future<CategoryResponse?> getCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return null;

    try {
      return CategoryResponse.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }
}
