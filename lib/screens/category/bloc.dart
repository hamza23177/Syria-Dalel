import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../local/category_cache.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import 'event.dart';
import 'state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService service;

  // سنحفظ البيانات هنا لضمان عدم ضياعها
  List<Category> _allCategories = [];

  CategoryBloc(this.service) : super(CategoryInitial()) {
    on<FetchCategories>(_onFetchCategories);
  }

  Future<void> _onFetchCategories(
      FetchCategories event,
      Emitter<CategoryState> emit,
      ) async {

    // 1️⃣ خطوة استباقية: إذا كان لدينا بيانات والطلب ليس "تحديث قسري"، نعرض الموجود
    if (_allCategories.isNotEmpty && !event.forceRefresh) {
      emit(CategoryLoaded(
        CategoryResponse(data: _allCategories, links: Links(), meta: Meta.empty()),
        isLoadingMore: false,
        isOffline: false,
      ));
      return;
    }

    emit(CategoryLoading());

    // 2️⃣ استراتيجية "الكاش أولاً" (Cache-First Strategy)
    // نعرض الكاش للمستخدم فوراً حتى لا ينتظر، ثم نذهب للإنترنت
    if (!event.forceRefresh) {
      final cached = await CategoryCacheService.getCachedCategories();
      if (cached != null && cached.data.isNotEmpty) {
        _allCategories = cached.data;
        emit(CategoryLoaded(
            cached,
            isLoadingMore: false,
            isOffline: true // نضع علامة أنه أوفلاين مؤقتاً
        ));
      }
    }

    // 3️⃣ التحقق من الاتصال
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (_allCategories.isNotEmpty) {
        // إذا كان لدينا كاش، نبقيه كما هو ولكن نعلم الواجهة
        emit(CategoryLoaded(
            CategoryResponse(data: _allCategories, links: Links(), meta: Meta.empty()),
            isOffline: true
        ));
      } else {
        emit(CategoryError("تأكد من اتصالك بالإنترنت"));
      }
      return;
    }

    // 4️⃣ جلب البيانات الحديثة (Full Sync)
    try {
      // 🔥 نطلب 1000 عنصر لضمان وصول كل الأقسام للفلترة
      final response = await service.fetchCategories(page: 1, perPage: 1000);

      // تحديث القائمة المحلية
      _allCategories = response.data;

      // حفظ في الكاش للمرة القادمة
      await CategoryCacheService.saveCategories(response);

      emit(CategoryLoaded(
        CategoryResponse(
          data: List.from(_allCategories),
          links: response.links ?? Links(),
          meta: response.meta ?? Meta.empty(),
        ),
        isLoadingMore: false,
        isOffline: false, // الآن نحن أونلاين ومحدثين
      ));

    } catch (e) {
      // في حال فشل السيرفر، هل لدينا كاش قديم؟
      if (_allCategories.isNotEmpty) {
        // نبقي القديم مع إشعار خطأ صامت (أو سناك بار في الواجهة)
        emit(CategoryLoaded(
            CategoryResponse(data: _allCategories, links: Links(), meta: Meta.empty()),
            isOffline: true // نعتبره أوفلاين لأن التحديث فشل
        ));
      } else {
        emit(CategoryError(e.toString().replaceAll("Exception: ", "")));
      }
    }
  }
}