import '../../../models/service_model.dart';
import '../../../services/service_api.dart';

class ServiceRepository {
  final ServiceApi api;

  ServiceRepository(this.api);

  Future<ServiceResponse> getServices({
    int perPage = 10,
    int page = 1,
    String? name,
    int? subCategoryId,
  }) {
    return api.fetchServices(
      perPage: perPage,
      page: page,
      name: name,
      subCategoryId: subCategoryId,
    );
  }

}
