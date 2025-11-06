import 'package:hive/hive.dart';
import '../../models/ad_model.dart';

class AdCache {
  static const _boxName = 'ad_box';

  Future<void> saveAds(List<AdModel> ads) async {
    final box = await Hive.openBox(_boxName);
    final adsJson = ads.map((e) => e.toJson()).toList();
    await box.put('ads', adsJson);
  }

  Future<List<AdModel>> getAds() async {
    final box = await Hive.openBox(_boxName);
    final data = box.get('ads', defaultValue: []);
    if (data is List) {
      return data
          .map((e) => AdModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}
