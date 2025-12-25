import 'package:equatable/equatable.dart';
import '../../models/category_model.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final CategoryResponse response;
  final bool isLoadingMore;
  final bool isOffline;

  CategoryLoaded(
      this.response, {
        this.isLoadingMore = false,
        this.isOffline = false, // 🔹 القيمة الافتراضية
      });

  @override
  List<Object?> get props => [response, isLoadingMore];
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
