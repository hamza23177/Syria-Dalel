import '../../models/service_model.dart';

abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final ServiceModel service;
  ServiceLoaded(this.service);
}

class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
}
