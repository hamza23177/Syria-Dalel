// bloc/home/home_state.dart
import 'package:equatable/equatable.dart';
import '../../models/home_model.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeData data;
  final bool isLoadingMore;

  HomeLoaded(this.data, {this.isLoadingMore = false});

  @override
  List<Object?> get props => [data];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
