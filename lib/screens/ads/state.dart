import 'package:equatable/equatable.dart';
import '../../models/ad_model.dart';

abstract class AdState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdInitial extends AdState {}

class AdLoading extends AdState {}

class AdLoaded extends AdState {
  final List<AdModel> ads;
  AdLoaded(this.ads);

  @override
  List<Object?> get props => [ads];
}

class AdError extends AdState {
  final String message;
  AdError(this.message);

  @override
  List<Object?> get props => [message];
}
