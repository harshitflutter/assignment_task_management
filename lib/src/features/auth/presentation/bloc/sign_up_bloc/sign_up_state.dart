part of 'sign_up_bloc.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

final class SignUpInitial extends SignUpState {}

class SignUpLoadingState extends SignUpState {}

class SignUpSuccessState extends SignUpState {
  final String successMessage;

  const SignUpSuccessState({required this.successMessage});
  @override
  List<Object> get props => [successMessage];
}

final class SignUpFailedState extends SignUpState {
  final String errorMessage;

  const SignUpFailedState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class AgreeTermsConditionState extends SignUpState {
  final bool status;

  const AgreeTermsConditionState({required this.status});
  @override
  List<Object> get props => [status];
}

class ShowHideConfirmPasswordState extends SignUpState {
  final bool status;

  const ShowHideConfirmPasswordState({required this.status});
  @override
  List<Object> get props => [status];
}

class ShowHidePasswordState extends SignUpState {
  final bool status;

  const ShowHidePasswordState({required this.status});
  @override
  List<Object> get props => [status];
}
