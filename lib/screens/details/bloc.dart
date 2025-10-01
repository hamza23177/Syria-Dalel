import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/service_api.dart';
import 'event.dart';
import 'state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceApi serviceService;

  ServiceBloc(this.serviceService) : super(ServiceInitial()) {
    on<LoadServiceDetails>((event, emit) async {
      emit(ServiceLoading());
      try {
        final service = await serviceService.fetchServiceDetails(event.id);
        emit(ServiceLoaded(service));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });
  }
}
