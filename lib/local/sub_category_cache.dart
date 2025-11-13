import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sub_category_model.dart';

class SubCategoryCacheService {
  static String _key(int categoryId) => 'cached_sub_categories_$categoryId';

  static Future<void> saveSubCategories(int categoryId, SubCategoryResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(categoryId), jsonEncode(response.toJson()));
  }

  static Future<SubCategoryResponse?> getCachedSubCategories(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key(categoryId));
    if (data == null) return null;
    try {
      return SubCategoryResponse.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }
}
