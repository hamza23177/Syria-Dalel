import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled2/screens/prod/service_repository.dart';
import 'event.dart';
import 'state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository repository;

  ServiceBloc(this.repository) : super(ServiceInitial()) {
    on<FetchServices>((event, emit) async {
      emit(ServiceLoading());
      try {
        final services = await repository.getServices(
          subCategoryId: event.subCategoryId,
          name: event.search,
        );
        emit(ServiceLoaded(services));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });
  }
}
