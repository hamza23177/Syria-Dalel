// features/category/bloc/sub_category_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/sub_category_service.dart';
import 'event.dart';
import 'state.dart';


class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  final SubCategoryService service;

  SubCategoryBloc(this.service) : super(SubCategoryInitial()) {
    on<FetchSubCategories>((event, emit) async {
      emit(SubCategoryLoading());
      try {
        final response = await service.fetchSubCategories(
          categoryId: event.categoryId,
          page: event.page,
          name: event.name,
        );
        emit(SubCategoryLoaded(
          subCategories: response.data,
          meta: response.meta,
        ));
      } catch (e) {
        emit(SubCategoryError(e.toString()));
      }
    });
  }
}
