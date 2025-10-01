// area_state.dart
import '../../models/area_model.dart';

abstract class AreaState {}

class AreaInitial extends AreaState {}

class AreaLoading extends AreaState {}

class AreaLoaded extends AreaState {
  final List<Area> areas;
  AreaLoaded(this.areas);
}

class AreaError extends AreaState {
  final String message;
  AreaError(this.message);
}
