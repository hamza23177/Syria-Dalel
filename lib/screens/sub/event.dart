// features/category/bloc/sub_category_event.dart
abstract class SubCategoryEvent {}

class FetchSubCategories extends SubCategoryEvent {
  final int categoryId;
  final int page;
  final String? name;

  FetchSubCategories({
    required this.categoryId,
    this.page = 1,
    this.name,
  });
}
