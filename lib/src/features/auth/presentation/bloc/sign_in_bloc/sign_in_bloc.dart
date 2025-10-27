import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Bloc, Emitter;
import 'package:task_management/src/core/services/local_storage_service/hive_storage_keys.dart';
import 'package:task_management/src/core/services/local_storage_service/hive_storage_service.dart';

import '../../../domain/repositories/auth_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isAgreeTermsCondition = false;
  bool isShowPassword = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AuthRepo authRepo;

  SignInBloc({required this.authRepo}) : super(SignInInitial()) {
    on<ShowHidePasswordEvent>(hideShowPassword);
    on<CallSignInEvent>(callSignInEvent);
    on<AgreeTermsConditionEvent>(callAgreeTermEvent);
  }

  Future<void> callSignInEvent(
    CallSignInEvent event,
    Emitter<SignInState> emit,
  ) async {
    // emailController.text = "hardik.flutterdev@gmail.com";
    // passwordController.text = "Hardik@9090";

    if (formKey.currentState!.validate()) {
      if (!isAgreeTermsCondition) {
        emit(
          const SignInFailedState(
            errorMessage: "Please agree terms and condition",
          ),
        );
        return;
      }
      emit(SignInLoadingState());
      try {
        final user = await authRepo.signIn(
          email: emailController.text,
          password: passwordController.text,
        );
        if (user != null) {
          HiveStorageService().saveValue(HiveStorageKey.userId, user.uid);
          emit(const SignInSuccessState(successMessage: "Sign In successful"));
        } else {
          emit(const SignInFailedState(errorMessage: "User not found"));
        }
      } catch (e) {
        emit(SignInFailedState(errorMessage: e.toString()));
      }
    }
  }

  Future<void> callAgreeTermEvent(
    AgreeTermsConditionEvent event,
    Emitter<SignInState> emit,
  ) async {
    try {
      isAgreeTermsCondition = event.isAgree;
      emit(AgreeTermsConditionState(status: isAgreeTermsCondition));
    } catch (e) {
      emit(SignInFailedState(errorMessage: e.toString()));
    }
  }

  Future<void> hideShowPassword(
    ShowHidePasswordEvent event,
    Emitter<SignInState> emit,
  ) async {
    try {
      isShowPassword = !isShowPassword;
      emit(ShowHidePasswordState(status: isShowPassword));
    } catch (e) {
      emit(SignInFailedState(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
