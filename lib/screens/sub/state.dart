import '../../models/sub_category_model.dart';

abstract class SubCategoryState {}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategoryLoaded extends SubCategoryState {
  final List<SubCategory> subCategories;
  final Meta meta;
  final bool isLoadingMore;

  SubCategoryLoaded({
    required this.subCategories,
    required this.meta,
    this.isLoadingMore = false,
  });
}

class SubCategoryError extends SubCategoryState {
  final String message;

  SubCategoryError(this.message);
}
