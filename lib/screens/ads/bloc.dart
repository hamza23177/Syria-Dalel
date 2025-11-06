import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../repositories/ad_repository.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final AdRepository repository;

  AdBloc(this.repository) : super(AdInitial()) {
    on<FetchAdsEvent>((event, emit) async {
      emit(AdLoading());

      try {
        // ✅ عرض الكاش فورًا إذا موجود
        final cachedAds = await repository.cache.getAds();
        if (cachedAds.isNotEmpty) {
          emit(AdLoaded(cachedAds));
        }

        // ✅ جلب البيانات من الإنترنت
        final ads = await repository.getAds();
        emit(AdLoaded(ads));
      } catch (_) {
        // إذا لم يكن هناك كاش، عرض خطأ
        final cachedAds = await repository.cache.getAds();
        if (cachedAds.isNotEmpty) {
          emit(AdLoaded(cachedAds));
        } else {
          emit(AdError("فشل تحميل الإعلانات. تحقق من الاتصال بالإنترنت."));
        }
      }
    });
  }
}

