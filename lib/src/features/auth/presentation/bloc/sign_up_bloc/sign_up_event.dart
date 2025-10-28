part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequestedEvent extends SignUpEvent {
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final bool agreeTerms;

  const SignUpRequestedEvent({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.agreeTerms,
  });

  @override
  List<Object> get props =>
      [fullName, username, email, password, confirmPassword, agreeTerms];
}

class SignUpPasswordVisibilityToggledEvent extends SignUpEvent {
  const SignUpPasswordVisibilityToggledEvent();

  @override
  List<Object> get props => [];
}

class SignUpConfirmPasswordVisibilityToggledEvent extends SignUpEvent {
  const SignUpConfirmPasswordVisibilityToggledEvent();

  @override
  List<Object> get props => [];
}

class SignUpResetEvent extends SignUpEvent {
  const SignUpResetEvent();

  @override
  List<Object> get props => [];
}

class SignUpFormValidatedEvent extends SignUpEvent {
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final bool agreeTerms;

  const SignUpFormValidatedEvent({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.agreeTerms,
  });

  @override
  List<Object> get props =>
      [fullName, username, email, password, confirmPassword, agreeTerms];
}

class SignUpLoadingStateChangedEvent extends SignUpEvent {
  final bool isLoading;

  const SignUpLoadingStateChangedEvent(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class SignUpFullNameChangedEvent extends SignUpEvent {
  final String fullName;

  const SignUpFullNameChangedEvent(this.fullName);

  @override
  List<Object> get props => [fullName];
}

class SignUpUsernameChangedEvent extends SignUpEvent {
  final String username;

  const SignUpUsernameChangedEvent(this.username);

  @override
  List<Object> get props => [username];
}

class SignUpEmailChangedEvent extends SignUpEvent {
  final String email;

  const SignUpEmailChangedEvent(this.email);

  @override
  List<Object> get props => [email];
}

class SignUpPasswordChangedEvent extends SignUpEvent {
  final String password;

  const SignUpPasswordChangedEvent(this.password);

  @override
  List<Object> get props => [password];
}

class SignUpConfirmPasswordChangedEvent extends SignUpEvent {
  final String confirmPassword;

  const SignUpConfirmPasswordChangedEvent(this.confirmPassword);

  @override
  List<Object> get props => [confirmPassword];
}

class SignUpTermsChangedEvent extends SignUpEvent {
  final bool agreeTerms;

  const SignUpTermsChangedEvent(this.agreeTerms);

  @override
  List<Object> get props => [agreeTerms];
}

class SignUpInitializeAnimationsEvent extends SignUpEvent {
  const SignUpInitializeAnimationsEvent();

  @override
  List<Object> get props => [];
}
