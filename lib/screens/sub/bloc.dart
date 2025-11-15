import 'package:flutter_bloc/flutter_bloc.dart';
import '../../local/sub_category_cache.dart';
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

    // 🔹 أول صفحة (جرب الكاش أولاً)
    if (currentPage == 1) {
      final cached = await SubCategoryCacheService.getCachedSubCategories(event.categoryId);
      if (cached != null && cached.data.isNotEmpty) {
        _subCategories = cached.data;
        emit(SubCategoryLoaded(
          subCategories: cached.data,
          meta: cached.meta,
          isLoadingMore: false,
        ));
      } else {
        emit(SubCategoryLoading());
      }
    } else {
      // 🔹 تحميل صفحات إضافية
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
        final existingIds = _subCategories.map((e) => e.id).toSet();
        final filtered = newItems.where((n) => !existingIds.contains(n.id)).toList();

        _subCategories.addAll(filtered);
        currentPage++;
      }

      emit(SubCategoryLoaded(
        subCategories: List<SubCategory>.from(_subCategories),
        meta: response.meta,
        isLoadingMore: false,
      ));
    } catch (e) {
      // 🔥 لا نحذف البيانات القديمة عند الخطأ (كاش موجود)
      if (_subCategories.isNotEmpty) {
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
          isLoadingMore: false,
        ));
      } else {
        emit(SubCategoryError(e.toString()));
      }
    }

    isLoading = false;
  }
}
