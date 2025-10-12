import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../services/contact_api.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactApi contactApi;

  ContactBloc(this.contactApi) : super(ContactInitial()) {
    on<LoadContactInfo>((event, emit) async {
      emit(ContactLoading());
      try {
        final contact = await contactApi.fetchContactInfo();
        emit(ContactLoaded(contact));
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });
  }
}
