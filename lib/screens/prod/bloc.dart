import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled2/screens/prod/service_repository.dart';
import '../../models/service_model.dart'; // تأكد من المسار
import 'event.dart';
import 'state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository repository;

  ServiceBloc(this.repository) : super(ServiceInitial()) {

    // 1️⃣ معالج جلب البيانات (كما هو لكن مع التأكد من الترتيب)
    on<FetchServices>(_onFetchServices);

    // 2️⃣ 🔥 حدث جديد: إضافة خدمة يدوياً للقائمة (لأجل الإبهار الفوري)
    on<InjectNewService>(_onInjectNewService);
  }

  Future<void> _onFetchServices(FetchServices event, Emitter<ServiceState> emit) async {
    final currentState = state;
    try {
      if (event.loadMore && currentState is ServiceLoaded) {
        if (currentState.isLoadingMore || currentState.currentPage >= currentState.lastPage) return;

        emit(currentState.copyWith(isLoadingMore: true));

        final nextPage = currentState.currentPage + 1;

        // هنا السيرفر سيرسل البيانات الأحدث في الصفحة التالية
        final response = await repository.getServices(
          subCategoryId: event.subCategoryId,
          name: event.search,
          page: nextPage,
        );

        emit(currentState.copyWith(
          services: List.from(currentState.services)..addAll(response.data),
          currentPage: response.meta.currentPage,
          lastPage: response.meta.lastPage,
          isLoadingMore: false,
        ));
      } else {
        emit(ServiceLoading());
        // الصفحة رقم 1 ستجلب أحدث الخدمات المضافة حديثاً
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
      emit(ServiceError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // 🔥 الدالة السحرية: تضع الخدمة الجديدة في القمة فوراً دون انتظار السيرفر
  void _onInjectNewService(InjectNewService event, Emitter<ServiceState> emit) {
    if (state is ServiceLoaded) {
      final currentState = state as ServiceLoaded;

      // ننشئ قائمة جديدة ونضع العنصر الجديد في البداية (index 0)
      final updatedList = List<ServiceModel>.from(currentState.services)
        ..insert(0, event.newService);

      emit(currentState.copyWith(services: updatedList));
    }
  }
}