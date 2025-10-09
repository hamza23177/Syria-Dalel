import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../services/ad_service.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final AdService adService;

  AdBloc(this.adService) : super(AdInitial()) {
    on<FetchAdsEvent>((event, emit) async {
      emit(AdLoading());
      try {
        final ads = await adService.fetchHomeAds();
        emit(AdLoaded(ads));
      } catch (e) {
        emit(AdError(e.toString()));
      }
    });
  }
}
