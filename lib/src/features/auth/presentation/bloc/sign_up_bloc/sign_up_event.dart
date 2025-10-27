part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class CallSignUpEvent extends SignUpEvent {
  const CallSignUpEvent();

  @override
  List<Object> get props => [];
}

class AgreeTermsConditionEvent extends SignUpEvent {
  final bool isAgree;
  const AgreeTermsConditionEvent({required this.isAgree});

  @override
  List<Object> get props => [isAgree];
}

class ShowHidePasswordEvent extends SignUpEvent {
  const ShowHidePasswordEvent();

  @override
  List<Object> get props => [];
}

class ShowHideConfirmPasswordEvent extends SignUpEvent {
  const ShowHideConfirmPasswordEvent();

  @override
  List<Object> get props => [];
}
