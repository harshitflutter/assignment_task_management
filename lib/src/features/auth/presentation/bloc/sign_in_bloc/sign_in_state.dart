part of 'sign_in_bloc.dart';

sealed class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

final class SignInInitial extends SignInState {}

class AgreeTermsConditionState extends SignInState {
  final bool status;

  const AgreeTermsConditionState({required this.status});
  @override
  List<Object> get props => [status];
}

class SignInLoadingState extends SignInState {}

final class SignInSuccessState extends SignInState {
  final String successMessage;

  const SignInSuccessState({required this.successMessage});
  @override
  List<Object> get props => [successMessage];
}

final class SignInFailedState extends SignInState {
  final String errorMessage;

  const SignInFailedState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class ShowHidePasswordState extends SignInState {
  final bool status;

  const ShowHidePasswordState({required this.status});
  @override
  List<Object> get props => [status];
}
