import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCategories extends CategoryEvent {
  final bool forceRefresh; // 🔹 هل المستخدم سحب للشاشة للتحديث؟

  FetchCategories({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}