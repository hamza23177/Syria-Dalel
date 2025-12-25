// import 'package:equatable/equatable.dart';
// import '../../models/home_model.dart';
//
// abstract class HomeState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
//
// class HomeInitial extends HomeState {}
//
// class HomeLoading extends HomeState {}
//
// class HomeLoaded extends HomeState {
//   final HomeData data;
//   final bool isLoadingMore;
//   final bool reachedEnd;
//   HomeLoaded(this.data, {this.isLoadingMore = false, this.reachedEnd = false});
//
//   @override
//   List<Object?> get props => [data, isLoadingMore, reachedEnd];
// }
//
// class HomeError extends HomeState {
//   final String message;
//   HomeError(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
