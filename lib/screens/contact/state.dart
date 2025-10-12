import 'package:equatable/equatable.dart';
import '../../models/contact_model.dart';

abstract class ContactState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactLoaded extends ContactState {
  final ContactModel contact;
  ContactLoaded(this.contact);

  @override
  List<Object?> get props => [contact];
}

class ContactError extends ContactState {
  final String message;
  ContactError(this.message);

  @override
  List<Object?> get props => [message];
}
