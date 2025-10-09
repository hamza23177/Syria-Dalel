import 'package:equatable/equatable.dart';

abstract class AdEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAdsEvent extends AdEvent {}
