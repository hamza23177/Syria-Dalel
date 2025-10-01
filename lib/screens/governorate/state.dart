// governorate_state.dart
import '../../models/category_model.dart';
import '../../models/governorate_model.dart';

abstract class GovernorateState {}

class GovernorateInitial extends GovernorateState {}

class GovernorateLoading extends GovernorateState {}

class GovernorateLoaded extends GovernorateState {
  final List<Governorate> governorates;
  GovernorateLoaded(this.governorates);
}

class GovernorateError extends GovernorateState {
  final String message;
  GovernorateError(this.message);
}
