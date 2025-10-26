import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled2/screens/prod/service_repository.dart';
import 'event.dart';
import 'state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository repository;

  ServiceBloc(this.repository) : super(ServiceInitial()) {
    on<FetchServices>((event, emit) async {
      final currentState = state;
      try {
        if (event.loadMore && currentState is ServiceLoaded) {
          if (currentState.isLoadingMore || currentState.currentPage >= currentState.lastPage) return;

          // Emit حالة تحميل إضافية (لإظهار loader أسفل القائمة)
          emit(currentState.copyWith(isLoadingMore: true));

          final nextPage = currentState.currentPage + 1;
          final response = await repository.getServices(
            subCategoryId: event.subCategoryId,
            name: event.search,
            page: nextPage,
          );

          emit(
            currentState.copyWith(
              services: List.from(currentState.services)..addAll(response.data),
              currentPage: response.meta.currentPage,
              lastPage: response.meta.lastPage,
              isLoadingMore: false,
            ),
          );
        } else {
          emit(ServiceLoading());
          final response = await repository.getServices(
            subCategoryId: event.subCategoryId,
            name: event.search,
            page: 1,
          );
          emit(ServiceLoaded(
            services: response.data,
            currentPage: response.meta.currentPage,
            lastPage: response.meta.lastPage,
            isLoadingMore: false,
          ));
        }
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });


  }
}
