import '../../models/sub_category_model.dart';

abstract class SubCategoryState {}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategoryLoaded extends SubCategoryState {
  final List<SubCategory> subCategories;
  final Meta meta;

  SubCategoryLoaded({required this.subCategories, required this.meta});
}

class SubCategoryError extends SubCategoryState {
  final String message;

  SubCategoryError(this.message);
}
