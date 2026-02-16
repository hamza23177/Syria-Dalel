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
    // إصلاح: التعامل مع جميع أنواع الاتصال
    bool isConnected = connectivityResult != ConnectivityResult.none;

    // حالة التحميل الأولية
    if (currentPage == 1 && _categories.isEmpty) {
      emit(CategoryLoading());
    }

    // --- سيناريو عدم الاتصال (Offline) ---
    if (!isConnected) {
      try {
        final cached = await CategoryCacheService.getCachedCategories();
        if (cached != null && cached.data.isNotEmpty) {
          if (currentPage == 1) {
            _categories = List.from(cached.data); // نسخ القائمة
          }
          emit(CategoryLoaded(
            CategoryResponse(
              data: List.from(_categories),
              links: Links(),
              meta: Meta.empty(),
            ),
            isLoadingMore: false,
            isOffline: true,
          ));
        } else {
          emit(CategoryError("لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة"));
        }
      } catch (e) {
        emit(CategoryError("خطأ في استرجاع البيانات المحفوظة"));
      }
      isLoading = false;
      return;
    }

    // --- سيناريو الاتصال (Online) ---
    try {
      // إرسال حالة تحميل للصفحات التالية دون حذف البيانات القديمة
      if (currentPage > 1) {
        emit(CategoryLoaded(
          CategoryResponse(
              data: List.from(_categories),
              links: Links(),
              meta: Meta.empty()),
          isLoadingMore: true,
          isOffline: false,
        ));
      }

      final response = await service.fetchCategories(page: currentPage);

      // دمج البيانات الجديدة مع منع التكرار (Best Practice)
      if (response.data.isEmpty) {
        hasMore = false;
      } else {
        final existingIds = _categories.map((e) => e.id).toSet();
        final newUniqueCategories = response.data
            .where((item) => !existingIds.contains(item.id))
            .toList();

        _categories.addAll(newUniqueCategories);

        // حفظ الصفحة الأولى فقط في الكاش لضمان السرعة عند الفتح القادم
        if (currentPage == 1) {
          await CategoryCacheService.saveCategories(response);
        }
        currentPage++;
      }

      emit(CategoryLoaded(
        CategoryResponse(
          data: List.from(_categories),
          links: response.links ?? Links(),
          meta: response.meta ?? Meta.empty(),
        ),
        isLoadingMore: false,
        isOffline: false,
      ));

    } catch (e) {
      // Fallback: العودة للكاش في حال فشل الـ API
      if (_categories.isNotEmpty) {
        emit(CategoryLoaded(
            CategoryResponse(data: List.from(_categories), links: Links(), meta: Meta.empty()),
            isLoadingMore: false,
            isOffline: true // نعتبرها أوفلاين لأن الطلب فشل
        ));
      } else {
        emit(CategoryError("حدث خطأ في الاتصال: $e"));
      }
    } finally {
      isLoading = false;
    }
  }
}