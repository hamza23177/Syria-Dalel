// area_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/area_service.dart';
import 'event.dart';
import 'state.dart';

class AreaBloc extends Bloc<AreaEvent, AreaState> {
  final AreaService service;

  AreaBloc(this.service) : super(AreaInitial()) {
    on<LoadAreas>((event, emit) async {
      emit(AreaLoading());
      try {
        final areas = await service.getAreas();
        emit(AreaLoaded(areas));
      } catch (e) {
        emit(AreaError(e.toString()));
      }
    });
  }
}
