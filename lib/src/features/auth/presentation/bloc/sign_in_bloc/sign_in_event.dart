part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class CallSignInEvent extends SignInEvent {
  const CallSignInEvent();

  @override
  List<Object> get props => [];
}

class AgreeTermsConditionEvent extends SignInEvent {
  final bool isAgree;
  const AgreeTermsConditionEvent({required this.isAgree});

  @override
  List<Object> get props => [isAgree];
}

class ShowHidePasswordEvent extends SignInEvent {
  const ShowHidePasswordEvent();

  @override
  List<Object> get props => [];
}
