import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';
import '../../models/service_model.dart';
import '../../screens/prod/service_repository.dart'; // تأكد من المسار

// --- Events ---
abstract class SearchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

// --- States ---
abstract class SearchState extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}
class SearchEmpty extends SearchState {} // لا توجد نتائج

class SearchSuccess extends SearchState {
  final List<ServiceModel> results;
  SearchSuccess(this.results);

  @override
  List<Object> get props => [results];
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class GlobalSearchBloc extends Bloc<SearchEvent, SearchState> {
  final ServiceRepository repository;

  GlobalSearchBloc(this.repository) : super(SearchInitial()) {

    // هذه هي الحركة السحرية (Debounce)
    on<SearchQueryChanged>(
          (event, emit) async {
        if (event.query.isEmpty) {
          emit(SearchInitial());
          return;
        }

        emit(SearchLoading());

        try {
          // نرسل الـ name للسيرفر، وهو سيبحث في كل الخدمات كما طلبت
          final response = await repository.getServices(
            name: event.query,
            page: 1, // نبحث في الصفحة الأولى
            perPage: 20, // نجلب عدد كافٍ من النتائج
          );

          if (response.data.isEmpty) {
            emit(SearchEmpty());
          } else {
            emit(SearchSuccess(response.data));
          }
        } catch (e) {
          emit(SearchError("حدث خطأ أثناء البحث، حاول مرة أخرى"));
        }
      },
      // ننتظر 500 ميلي ثانية بعد توقف الكتابة قبل إرسال الطلب
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .asyncExpand(mapper),
    );
  }
}