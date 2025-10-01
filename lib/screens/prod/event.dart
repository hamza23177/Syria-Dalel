import 'package:equatable/equatable.dart';

abstract class ServiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchServices extends ServiceEvent {
  final int subCategoryId;
  final String? search;

  FetchServices({required this.subCategoryId, this.search});
}
