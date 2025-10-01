import '../../../models/service_model.dart';
import '../../../services/service_api.dart';

class ServiceRepository {
  final ServiceApi api;

  ServiceRepository(this.api);

  Future<List<ServiceModel>> getServices({
    int perPage = 10,
    String? name,
    int? subCategoryId,
  }) {
    return api.fetchServices(
      perPage: perPage,
      name: name,
      subCategoryId: subCategoryId,
    );
  }
}
