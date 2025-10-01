// governorate_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled2/models/category_model.dart';
import '../../models/governorate_model.dart';
import '../../services/governorate_service.dart';
import 'event.dart';
import 'state.dart';

class GovernorateBloc extends Bloc<GovernorateEvent, GovernorateState> {
  final GovernorateService service;

  GovernorateBloc(this.service) : super(GovernorateInitial()) {
    on<LoadGovernorates>((event, emit) async {
      emit(GovernorateLoading());
      try {
        final governorates = await service.getGovernorates();
        emit(GovernorateLoaded(governorates.cast<Governorate>()));
      } catch (e) {
        emit(GovernorateError(e.toString()));
      }
    });
  }
}
