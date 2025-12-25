import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

    final connectivityResult = await Connectivity().checkConnectivity();
    bool isConnected = connectivityResult != ConnectivityResult.none;

    if (currentPage == 1 && _categories.isEmpty) {
      emit(CategoryLoading());
    }

    // --- وضع عدم الاتصال (Offline) ---
    if (!isConnected) {
      final cached = await CategoryCacheService.getCachedCategories();

      if (cached != null && cached.data.isNotEmpty) {
        if (currentPage == 1) {
          _categories = cached.data;
        }

        emit(CategoryLoaded(
          CategoryResponse(
            data: List.from(_categories),
            links: Links(),
            meta: Meta.empty(), // ✅ تم الإصلاح: استخدام المنشئ الفارغ
          ),
          isLoadingMore: false,
          isOffline: true,
        ));
      } else {
        emit(CategoryError("لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة"));
      }

      isLoading = false;
      return;
    }

    // --- وضع الاتصال (Online) ---
    try {
      if (currentPage > 1) {
        emit(CategoryLoaded(
          // ✅ تم الإصلاح هنا أيضاً
          CategoryResponse(data: List.from(_categories), links: Links(), meta: Meta.empty()),
          isLoadingMore: true,
          isOffline: false,
        ));
      }

      final response = await service.fetchCategories(page: currentPage);
      final newCategories = response.data;

      if (newCategories.isEmpty) {
        hasMore = false;
      } else {
        final existingIds = _categories.map((e) => e.id).toSet();
        final filtered = newCategories.where((n) => !existingIds.contains(n.id)).toList();
        _categories.addAll(filtered);

        if (currentPage == 1) {
          // ✅ تم الإصلاح: اسم الدالة في السيرفس هو saveCategories وليس cacheCategories
          await CategoryCacheService.saveCategories(response);
        }

        currentPage++;
      }

      emit(CategoryLoaded(
        CategoryResponse(
          data: List.from(_categories),
          links: response.links ?? Links(),
          meta: response.meta,
        ),
        isLoadingMore: false,
        isOffline: false,
      ));

    } catch (e) {
      // في حال الخطأ
      if (_categories.isNotEmpty) {
        emit(CategoryLoaded(
          // ✅ تم الإصلاح
          CategoryResponse(data: List.from(_categories), links: Links(), meta: Meta.empty()),
          isLoadingMore: false,
          isOffline: true,
        ));
      } else {
        final cached = await CategoryCacheService.getCachedCategories();
        if (cached != null && cached.data.isNotEmpty) {
          _categories = cached.data;
          emit(CategoryLoaded(cached, isOffline: true));
        } else {
          emit(CategoryError("حدث خطأ أثناء الاتصال بالخادم"));
        }
      }
    }

    isLoading = false;
  }
}