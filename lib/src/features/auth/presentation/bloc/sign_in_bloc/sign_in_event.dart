part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class SignInRequestedEvent extends SignInEvent {
  final String email;
  final String password;
  final bool agreeTerms;

  const SignInRequestedEvent({
    required this.email,
    required this.password,
    required this.agreeTerms,
  });

  @override
  List<Object> get props => [email, password, agreeTerms];
}

class SignInPasswordVisibilityToggledEvent extends SignInEvent {
  const SignInPasswordVisibilityToggledEvent();

  @override
  List<Object> get props => [];
}

class SignInResetEvent extends SignInEvent {
  const SignInResetEvent();

  @override
  List<Object> get props => [];
}

class SignInFormValidatedEvent extends SignInEvent {
  final String email;
  final String password;
  final bool agreeTerms;

  const SignInFormValidatedEvent({
    required this.email,
    required this.password,
    required this.agreeTerms,
  });

  @override
  List<Object> get props => [email, password, agreeTerms];
}

class SignInLoadingStateChangedEvent extends SignInEvent {
  final bool isLoading;

  const SignInLoadingStateChangedEvent(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class SignInEmailChangedEvent extends SignInEvent {
  final String email;

  const SignInEmailChangedEvent(this.email);

  @override
  List<Object> get props => [email];
}

class SignInPasswordChangedEvent extends SignInEvent {
  final String password;

  const SignInPasswordChangedEvent(this.password);

  @override
  List<Object> get props => [password];
}

class SignInInitializeAnimationsEvent extends SignInEvent {
  const SignInInitializeAnimationsEvent();

  @override
  List<Object> get props => [];
}
