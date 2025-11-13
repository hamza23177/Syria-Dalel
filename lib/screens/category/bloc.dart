import 'package:flutter_bloc/flutter_bloc.dart';
import '../../local/category_cache.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import 'event.dart';
import 'state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService service;
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Category> _categories = [];

  CategoryBloc(this.service) : super(CategoryInitial()) {
    on<FetchCategories>(_onFetchCategories);
  }

  Future<void> _onFetchCategories(
      FetchCategories event,
      Emitter<CategoryState> emit,
      ) async {
    if (isLoading || !hasMore) return;
    isLoading = true;

    // 🔹 أول صفحة (نحاول الكاش أولاً)
    if (currentPage == 1) {
      final cached = await CategoryCacheService.getCachedCategories();
      if (cached != null && cached.data.isNotEmpty) {
        _categories = cached.data;
        emit(CategoryLoaded(cached, isLoadingMore: false));
      } else {
        emit(CategoryLoading());
      }
    } else {
      // 🔹 تحميل صفحات إضافية (عرض shimmer فقط)
      emit(CategoryLoaded(
        CategoryResponse(
          data: List<Category>.from(_categories),
          links: Links(first: '', last: '', prev: '', next: ''),
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
        ),
        isLoadingMore: true,
      ));
    }

    try {
      final response = await service.fetchCategories(page: currentPage);
      final newCategories = response.data;

      if (newCategories.isEmpty) {
        hasMore = false;
      } else {
        _categories = List<Category>.from(_categories)..addAll(newCategories);
        currentPage++;
      }

      emit(CategoryLoaded(
        CategoryResponse(
          data: List<Category>.from(_categories),
          links: response.links ?? Links(),
          meta: response.meta,
        ),
        isLoadingMore: false,
      ));
    } catch (e) {
      // 🔥 لا نحذف البيانات القديمة عند الخطأ
      if (_categories.isNotEmpty) {
        emit(CategoryLoaded(
          CategoryResponse(
            data: List<Category>.from(_categories),
            links: Links(first: '', last: '', prev: '', next: ''),
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
          ),
          isLoadingMore: false,
        ));
      }
    }

    isLoading = false;
  }
}
