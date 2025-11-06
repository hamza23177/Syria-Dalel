import '../local/ad_cache.dart';
import '../models/ad_model.dart';
import '../services/ad_service.dart';

class AdRepository {
  final AdService api;
  final AdCache cache;

  AdRepository({required this.api, required this.cache});

  Future<List<AdModel>> getAds() async {
    final cachedAds = await cache.getAds();
    try {
      final ads = await api.fetchHomeAds();
      await cache.saveAds(ads);
      return ads;
    } catch (_) {
      if (cachedAds.isNotEmpty) {
        return cachedAds; // عرض الكاش عند عدم وجود الإنترنت
      } else {
        rethrow;
      }
    }
  }
}
