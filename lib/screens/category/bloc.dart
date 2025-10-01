import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/category_model.dart';
import 'event.dart';
import 'state.dart';
import '../../services/category_service.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService service;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetching = false;
  final int perPage;

  List<Category> _allCategories = [];

  CategoryBloc(this.service, {this.perPage = 10}) : super(CategoryInitial()) {
    on<FetchCategories>((event, emit) async {
      if (!_hasMore || _isFetching) return;
      _isFetching = true;

      if (_currentPage == 1) emit(CategoryLoading());

      try {
        final response = await service.fetchCategories(
          page: _currentPage,
          perPage: perPage,
        );

        _allCategories.addAll(response.data);

        _hasMore = _currentPage < response.meta.lastPage;

        emit(CategoryLoaded(CategoryResponse(
          data: _allCategories,
          links: response.links,
          meta: response.meta,
        )));

        _currentPage++; // انتقل للصفحة التالية
      } catch (e) {
        emit(CategoryError(e.toString()));
      }

      _isFetching = false;
    });
  }
}





