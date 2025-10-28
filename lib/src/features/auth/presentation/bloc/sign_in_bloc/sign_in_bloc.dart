import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/services/local_storage_service/hive_storage_keys.dart';
import 'package:task_management/src/core/services/local_storage_service/hive_storage_service.dart';

import '../../../domain/repositories/auth_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthRepo _authRepo;

  SignInBloc({required AuthRepo authRepo})
      : _authRepo = authRepo,
        super(const SignInInitial()) {
    on<SignInRequestedEvent>(_onSignInRequested);
    on<SignInPasswordVisibilityToggledEvent>(_onPasswordVisibilityToggled);
    on<SignInResetEvent>(_onReset);
    on<SignInFormValidatedEvent>(_onFormValidated);
    on<SignInLoadingStateChangedEvent>(_onLoadingStateChanged);
    on<SignInEmailChangedEvent>(_onEmailChanged);
    on<SignInPasswordChangedEvent>(_onPasswordChanged);
    on<SignInInitializeAnimationsEvent>(_onInitializeAnimations);
  }

  Future<void> _onSignInRequested(
    SignInRequestedEvent event,
    Emitter<SignInState> emit,
  ) async {
    // Validate input
    final validationErrors = _validateSignInInput(event);
    if (validationErrors.isNotEmpty) {
      emit(SignInValidationErrorState(fieldErrors: validationErrors));
      return;
    }

    if (state is SignInInitial) {
      final currentState = state as SignInInitial;
      emit(SignInLoadingState(
        email: currentState.email,
        password: currentState.password,
        isPasswordVisible: currentState.isPasswordVisible,
        animationsInitialized: currentState.animationsInitialized,
      ));
    } else {
      emit(SignInLoadingState(
        email: event.email,
        password: event.password,
        isPasswordVisible: false,
        animationsInitialized: true,
      ));
    }

    try {
      final user = await _authRepo.signIn(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        // Save user ID to local storage
        HiveStorageService.instance.saveValue(HiveStorageKey.userId, user.uid);
        emit(const SignInSuccessState(
            successMessage: AppStrings.welcomeBackMessage));
      } else {
        emit(const SignInFailedState(
            errorMessage: AppStrings.invalidCredentials));
      }
    } on FirebaseAuthException catch (e) {
      emit(SignInFailedState(errorMessage: _getErrorMessage(e)));
    } catch (e) {
      emit(SignInFailedState(errorMessage: e.toString()));
    }
  }

  Future<void> _onPasswordVisibilityToggled(
    SignInPasswordVisibilityToggledEvent event,
    Emitter<SignInState> emit,
  ) async {
    if (state is SignInInitial) {
      final currentState = state as SignInInitial;
      emit(currentState.copyWith(
        isPasswordVisible: !currentState.isPasswordVisible,
      ));
    } else {
      // If not in initial state, create a new initial state with toggled visibility
      emit(const SignInInitial(isPasswordVisible: true));
    }
  }

  Future<void> _onReset(
    SignInResetEvent event,
    Emitter<SignInState> emit,
  ) async {
    emit(const SignInInitial());
  }

  Future<void> _onFormValidated(
    SignInFormValidatedEvent event,
    Emitter<SignInState> emit,
  ) async {
    final validationErrors = _validateSignInFormInput(event);
    if (validationErrors.isNotEmpty) {
      emit(SignInValidationErrorState(fieldErrors: validationErrors));
    } else {
      emit(SignInFormValidState());
    }
  }

  Future<void> _onLoadingStateChanged(
    SignInLoadingStateChangedEvent event,
    Emitter<SignInState> emit,
  ) async {
    if (state is SignInInitial) {
      final currentState = state as SignInInitial;
      if (event.isLoading) {
        emit(SignInLoadingState(
          email: currentState.email,
          password: currentState.password,
          isPasswordVisible: currentState.isPasswordVisible,
          animationsInitialized: currentState.animationsInitialized,
        ));
      } else {
        emit(currentState.copyWith(isLoading: false));
      }
    } else {
      // If not in initial state, create a new initial state
      emit(const SignInInitial());
    }
  }

  Future<void> _onEmailChanged(
    SignInEmailChangedEvent event,
    Emitter<SignInState> emit,
  ) async {
    if (state is SignInInitial) {
      final currentState = state as SignInInitial;
      emit(currentState.copyWith(email: event.email));
    } else {
      // If not in initial state, create a new initial state with the email
      emit(SignInInitial(email: event.email));
    }
  }

  Future<void> _onPasswordChanged(
    SignInPasswordChangedEvent event,
    Emitter<SignInState> emit,
  ) async {
    if (state is SignInInitial) {
      final currentState = state as SignInInitial;
      emit(currentState.copyWith(password: event.password));
    } else {
      // If not in initial state, create a new initial state with the password
      emit(SignInInitial(password: event.password));
    }
  }

  Future<void> _onInitializeAnimations(
    SignInInitializeAnimationsEvent event,
    Emitter<SignInState> emit,
  ) async {
    if (state is SignInInitial) {
      final currentState = state as SignInInitial;
      emit(currentState.copyWith(animationsInitialized: true));
    } else {
      // If not in initial state, create a new initial state with animations initialized
      emit(const SignInInitial(animationsInitialized: true));
    }
  }

  Map<String, String> _validateSignInInput(SignInRequestedEvent event) {
    final errors = <String, String>{};

    if (event.email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!_isValidEmail(event.email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    if (event.password.isEmpty) {
      errors['password'] = 'Password is required';
    }

    if (!event.agreeTerms) {
      errors['terms'] = 'Please agree to the terms and conditions';
    }

    return errors;
  }

  Map<String, String> _validateSignInFormInput(SignInFormValidatedEvent event) {
    final errors = <String, String>{};

    if (event.email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!_isValidEmail(event.email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    if (event.password.isEmpty) {
      errors['password'] = 'Password is required';
    }

    return errors;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getErrorMessage(FirebaseAuthException error) {
    if (error.toString().contains('user-not-found')) {
      return AppStrings.noAccountFound;
    } else if (error.toString().contains('wrong-password')) {
      return AppStrings.incorrectPasswordMessage;
    } else if (error.toString().contains('invalid-email')) {
      return AppStrings.pleaseEnterValidEmail;
    } else if (error.toString().contains('user-disabled')) {
      return AppStrings.accountDisabled;
    } else if (error.toString().contains('too-many-requests')) {
      return AppStrings.tooManyFailedAttempts;
    } else if (error.toString().contains('network')) {
      return AppStrings.networkError;
    } else {
      return error.message ?? AppStrings.unexpectedErrorMessage;
    }
  }

  // Validation methods for UI
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  bool isFormValid(String email, String password) {
    return validateEmail(email) == null && validatePassword(password) == null;
  }

  Map<String, String> getValidationErrors(String email, String password) {
    final errors = <String, String>{};

    final emailError = validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    return errors;
  }
}
