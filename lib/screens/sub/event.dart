abstract class SubCategoryEvent {}

class FetchSubCategories extends SubCategoryEvent {
  final int categoryId;
  final String? name;

  FetchSubCategories({
    required this.categoryId,
    this.name,
  });
}
