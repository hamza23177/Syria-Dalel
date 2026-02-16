import 'package:equatable/equatable.dart';

import '../../models/service_model.dart';

abstract class ServiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchServices extends ServiceEvent {
  final int? subCategoryId;
  final String? search;
  final bool loadMore;

  FetchServices({required this.subCategoryId, this.search, this.loadMore = false});
}

class InjectNewService extends ServiceEvent {
  final ServiceModel newService;
  InjectNewService(this.newService);
  @override
  List<Object?> get props => [newService];
}