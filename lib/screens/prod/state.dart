import 'package:equatable/equatable.dart';
import '../../../models/service_model.dart';

abstract class ServiceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}


class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  ServiceLoaded({
    required this.services,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
  });

  ServiceLoaded copyWith({
    List<ServiceModel>? services,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return ServiceLoaded(
      services: services ?? this.services,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [services, currentPage, lastPage, isLoadingMore];
}



class ServiceError extends ServiceState {
  final String message;

  ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
