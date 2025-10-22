// bloc/home/home_event.dart
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  final int page;
  final int perPage;

  LoadHomeData({this.page = 1, this.perPage = 10});

  @override
  List<Object?> get props => [page, perPage];
}

class LoadMoreHomeData extends HomeEvent {
  final int page;
  final int perPage;

  LoadMoreHomeData({required this.page, this.perPage = 10});

  @override
  List<Object?> get props => [page, perPage];
}
