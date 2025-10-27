import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../domain/repositories/auth_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  bool isShowPassword = true;
  bool isShowConfirmPassword = true;

  bool isAgreeTermsCondition = false;

  final AuthRepo authRepo;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SignUpBloc({required this.authRepo}) : super(SignUpInitial()) {
    on<CallSignUpEvent>((event, emit) async {
      if (passwordController.text != confirmPasswordController.text) {
        emit(
          const SignUpFailedState(
            errorMessage: "Password & confirm password not match",
          ),
        );
        return;
      }

      if (!isAgreeTermsCondition) {
        emit(
          const SignUpFailedState(
            errorMessage: "Please agree terms and condition",
          ),
        );
        return;
      }
      emit(SignUpLoadingState());

      if (formKey.currentState!.validate()) {
        try {
          final user = await authRepo.signUp(
            email: emailController.text,
            password: passwordController.text,
            fullName: fullNameController.text,
            username: usernameController.text,
          );
          if (user != null) {
            emit(
                const SignUpSuccessState(successMessage: "Sign In successful"));
          } else {
            emit(const SignUpFailedState(errorMessage: "User not found"));
          }
        } catch (e) {
          emit(SignUpFailedState(errorMessage: e.toString()));
        }
      }
    });

    on<AgreeTermsConditionEvent>((event, emit) async {
      try {
        isAgreeTermsCondition = event.isAgree;
        emit(AgreeTermsConditionState(status: isAgreeTermsCondition));
      } catch (e) {
        emit(SignUpFailedState(errorMessage: e.toString()));
      }
    });

    on<ShowHidePasswordEvent>(hideShowPassword);
    on<ShowHideConfirmPasswordEvent>(hideShowConfirmPassword);
  }

  Future<void> hideShowPassword(
    ShowHidePasswordEvent event,
    Emitter<SignUpState> emit,
  ) async {
    try {
      isShowPassword = !isShowPassword;
      emit(ShowHidePasswordState(status: isShowPassword));
    } catch (e) {
      emit(SignUpFailedState(errorMessage: e.toString()));
    }
  }

  Future<void> hideShowConfirmPassword(
    ShowHideConfirmPasswordEvent event,
    Emitter<SignUpState> emit,
  ) async {
    try {
      isShowConfirmPassword = !isShowConfirmPassword;
      emit(ShowHideConfirmPasswordState(status: isShowPassword));
    } catch (e) {
      emit(SignUpFailedState(errorMessage: e.toString()));
    }
  }
}
