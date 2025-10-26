import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/sub_category_model.dart';
import '../../services/sub_category_service.dart';
import 'event.dart';
import 'state.dart';

class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  final SubCategoryService service;

  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<SubCategory> _subCategories = [];

  SubCategoryBloc(this.service) : super(SubCategoryInitial()) {
    on<FetchSubCategories>(_onFetchSubCategories);
  }

  Future<void> _onFetchSubCategories(
      FetchSubCategories event,
      Emitter<SubCategoryState> emit,
      ) async {
    if (isLoading || !hasMore) return;
    isLoading = true;

    if (currentPage == 1) {
      emit(SubCategoryLoading());
    } else {
      emit(SubCategoryLoaded(
        subCategories: List<SubCategory>.from(_subCategories),
        meta: Meta(
          currentPage: currentPage,
          from: 0,
          lastPage: 0,
          links: [],
          path: '',
          perPage: 0,
          to: 0,
          total: 0,
        ),
        isLoadingMore: true,
      ));
    }

    try {
      final response = await service.fetchSubCategories(
        categoryId: event.categoryId,
        page: currentPage,
        name: event.name,
      );

      final newItems = response.data;

      if (newItems.isEmpty) {
        hasMore = false;
      } else {
        _subCategories.addAll(newItems);
        currentPage++;
      }

      emit(SubCategoryLoaded(
        subCategories: List<SubCategory>.from(_subCategories),
        meta: response.meta,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(SubCategoryError("فشل في تحميل البيانات: ${e.toString()}"));
    }

    isLoading = false;
  }
}
