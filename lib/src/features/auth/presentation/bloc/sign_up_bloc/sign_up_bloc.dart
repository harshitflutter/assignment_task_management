import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/core/constants/app_strings.dart';

import '../../../domain/repositories/auth_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepo _authRepo;

  SignUpBloc({required AuthRepo authRepo})
      : _authRepo = authRepo,
        super(const SignUpInitial()) {
    on<SignUpRequestedEvent>(_onSignUpRequested);
    on<SignUpPasswordVisibilityToggledEvent>(_onPasswordVisibilityToggled);
    on<SignUpConfirmPasswordVisibilityToggledEvent>(
        _onConfirmPasswordVisibilityToggled);
    on<SignUpResetEvent>(_onReset);
    on<SignUpFormValidatedEvent>(_onFormValidated);
    on<SignUpLoadingStateChangedEvent>(_onLoadingStateChanged);
    on<SignUpFullNameChangedEvent>(_onFullNameChanged);
    on<SignUpUsernameChangedEvent>(_onUsernameChanged);
    on<SignUpEmailChangedEvent>(_onEmailChanged);
    on<SignUpPasswordChangedEvent>(_onPasswordChanged);
    on<SignUpConfirmPasswordChangedEvent>(_onConfirmPasswordChanged);
    on<SignUpTermsChangedEvent>(_onTermsChanged);
    on<SignUpInitializeAnimationsEvent>(_onInitializeAnimations);
  }

  Future<void> _onSignUpRequested(
    SignUpRequestedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    // Validate input
    final validationErrors = _validateSignUpInput(event);
    if (validationErrors.isNotEmpty) {
      emit(SignUpValidationErrorState(fieldErrors: validationErrors));
      return;
    }

    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(SignUpLoadingState(
        fullName: currentState.fullName,
        username: currentState.username,
        email: currentState.email,
        password: currentState.password,
        confirmPassword: currentState.confirmPassword,
        isPasswordVisible: currentState.isPasswordVisible,
        isConfirmPasswordVisible: currentState.isConfirmPasswordVisible,
        agreeTerms: currentState.agreeTerms,
        animationsInitialized: currentState.animationsInitialized,
      ));
    } else {
      emit(SignUpLoadingState(
        fullName: event.fullName,
        username: event.username,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
        isPasswordVisible: false,
        isConfirmPasswordVisible: false,
        agreeTerms: event.agreeTerms,
        animationsInitialized: true,
      ));
    }

    try {
      final user = await _authRepo.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        username: event.username,
      );

      if (user != null) {
        emit(const SignUpSuccessState(
            successMessage: AppStrings.accountCreatedSuccessfully));
      } else {
        emit(const SignUpFailedState(
            errorMessage: AppStrings.failedToCreateAccount));
      }
    } on FirebaseAuthException catch (e) {
      emit(SignUpFailedState(errorMessage: _getErrorMessage(e)));
    } catch (e) {
      emit(SignUpFailedState(errorMessage: e.toString()));
    }
  }

  Future<void> _onPasswordVisibilityToggled(
    SignUpPasswordVisibilityToggledEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(
        isPasswordVisible: !currentState.isPasswordVisible,
      ));
    } else {
      emit(const SignUpInitial(isPasswordVisible: true));
    }
  }

  Future<void> _onConfirmPasswordVisibilityToggled(
    SignUpConfirmPasswordVisibilityToggledEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(
        isConfirmPasswordVisible: !currentState.isConfirmPasswordVisible,
      ));
    } else {
      emit(const SignUpInitial(isConfirmPasswordVisible: true));
    }
  }

  Future<void> _onReset(
    SignUpResetEvent event,
    Emitter<SignUpState> emit,
  ) async {
    emit(const SignUpInitial());
  }

  Future<void> _onFormValidated(
    SignUpFormValidatedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    final validationErrors = _validateSignUpFormInput(event);
    if (validationErrors.isNotEmpty) {
      emit(SignUpValidationErrorState(fieldErrors: validationErrors));
    } else {
      emit(SignUpFormValidState());
    }
  }

  Future<void> _onLoadingStateChanged(
    SignUpLoadingStateChangedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      if (event.isLoading) {
        emit(SignUpLoadingState(
          fullName: currentState.fullName,
          username: currentState.username,
          email: currentState.email,
          password: currentState.password,
          confirmPassword: currentState.confirmPassword,
          isPasswordVisible: currentState.isPasswordVisible,
          isConfirmPasswordVisible: currentState.isConfirmPasswordVisible,
          agreeTerms: currentState.agreeTerms,
          animationsInitialized: currentState.animationsInitialized,
        ));
      } else {
        emit(currentState.copyWith(isLoading: false));
      }
    } else {
      emit(const SignUpInitial());
    }
  }

  Future<void> _onFullNameChanged(
    SignUpFullNameChangedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(fullName: event.fullName));
    } else {
      emit(SignUpInitial(fullName: event.fullName));
    }
  }

  Future<void> _onUsernameChanged(
    SignUpUsernameChangedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(username: event.username));
    } else {
      emit(SignUpInitial(username: event.username));
    }
  }

  Future<void> _onEmailChanged(
    SignUpEmailChangedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(email: event.email));
    } else {
      emit(SignUpInitial(email: event.email));
    }
  }

  Future<void> _onPasswordChanged(
    SignUpPasswordChangedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(password: event.password));
    } else {
      emit(SignUpInitial(password: event.password));
    }
  }

  Future<void> _onConfirmPasswordChanged(
    SignUpConfirmPasswordChangedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(confirmPassword: event.confirmPassword));
    } else {
      emit(SignUpInitial(confirmPassword: event.confirmPassword));
    }
  }

  Future<void> _onTermsChanged(
    SignUpTermsChangedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(agreeTerms: event.agreeTerms));
    } else {
      emit(SignUpInitial(agreeTerms: event.agreeTerms));
    }
  }

  Future<void> _onInitializeAnimations(
    SignUpInitializeAnimationsEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(currentState.copyWith(animationsInitialized: true));
    } else {
      emit(const SignUpInitial(animationsInitialized: true));
    }
  }

  Map<String, String> _validateSignUpInput(SignUpRequestedEvent event) {
    final errors = <String, String>{};

    if (event.fullName.trim().isEmpty) {
      errors['fullName'] = AppStrings.pleaseEnterFullName;
    } else if (event.fullName.trim().length < 2) {
      errors['fullName'] = AppStrings.nameMinLength;
    }

    if (event.username.trim().isEmpty) {
      errors['username'] = AppStrings.pleaseEnterUsername;
    } else if (event.username.trim().length < 3) {
      errors['username'] = AppStrings.usernameMinLength;
    }

    if (event.email.trim().isEmpty) {
      errors['email'] = AppStrings.pleaseEnterEmail;
    } else if (!_isValidEmail(event.email)) {
      errors['email'] = AppStrings.pleaseEnterValidEmail;
    }

    if (event.password.isEmpty) {
      errors['password'] = AppStrings.pleaseEnterPassword;
    } else if (event.password.length < 6) {
      errors['password'] = AppStrings.passwordMinLength;
    }

    if (event.confirmPassword.isEmpty) {
      errors['confirmPassword'] = AppStrings.pleaseConfirmPassword;
    } else if (event.password != event.confirmPassword) {
      errors['confirmPassword'] = AppStrings.passwordsDoNotMatch;
    }

    if (!event.agreeTerms) {
      errors['terms'] = AppStrings.pleaseAgreeTerms;
    }

    return errors;
  }

  Map<String, String> _validateSignUpFormInput(SignUpFormValidatedEvent event) {
    final errors = <String, String>{};

    if (event.fullName.trim().isEmpty) {
      errors['fullName'] = AppStrings.pleaseEnterFullName;
    } else if (event.fullName.trim().length < 2) {
      errors['fullName'] = AppStrings.nameMinLength;
    }

    if (event.username.trim().isEmpty) {
      errors['username'] = AppStrings.pleaseEnterUsername;
    } else if (event.username.trim().length < 3) {
      errors['username'] = AppStrings.usernameMinLength;
    }

    if (event.email.trim().isEmpty) {
      errors['email'] = AppStrings.pleaseEnterEmail;
    } else if (!_isValidEmail(event.email)) {
      errors['email'] = AppStrings.pleaseEnterValidEmail;
    }

    if (event.password.isEmpty) {
      errors['password'] = AppStrings.pleaseEnterPassword;
    } else if (event.password.length < 6) {
      errors['password'] = AppStrings.passwordMinLength;
    }

    if (event.confirmPassword.isEmpty) {
      errors['confirmPassword'] = AppStrings.pleaseConfirmPassword;
    } else if (event.password != event.confirmPassword) {
      errors['confirmPassword'] = AppStrings.passwordsDoNotMatch;
    }

    if (!event.agreeTerms) {
      errors['terms'] = AppStrings.pleaseAgreeTerms;
    }

    return errors;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getErrorMessage(FirebaseAuthException error) {
    if (error.toString().contains('email-already-in-use')) {
      return AppStrings.emailAlreadyExists;
    } else if (error.toString().contains('weak-password')) {
      return AppStrings.passwordTooWeakMessage;
    } else if (error.toString().contains('invalid-email')) {
      return AppStrings.pleaseEnterValidEmail;
    } else if (error.toString().contains('network')) {
      return AppStrings.networkError;
    } else {
      return error.message ?? AppStrings.unexpectedErrorMessage;
    }
  }

  // Validation methods for UI
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

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

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool isFormValid(String fullName, String username, String email,
      String password, String confirmPassword, bool agreeTerms) {
    return validateFullName(fullName) == null &&
        validateUsername(username) == null &&
        validateEmail(email) == null &&
        validatePassword(password) == null &&
        validateConfirmPassword(confirmPassword, password) == null &&
        agreeTerms;
  }

  Map<String, String> getValidationErrors(String fullName, String username,
      String email, String password, String confirmPassword, bool agreeTerms) {
    final errors = <String, String>{};

    final fullNameError = validateFullName(fullName);
    if (fullNameError != null) {
      errors['fullName'] = fullNameError;
    }

    final usernameError = validateUsername(username);
    if (usernameError != null) {
      errors['username'] = usernameError;
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    final confirmPasswordError =
        validateConfirmPassword(confirmPassword, password);
    if (confirmPasswordError != null) {
      errors['confirmPassword'] = confirmPasswordError;
    }

    if (!agreeTerms) {
      errors['terms'] = 'Please agree to the terms and conditions';
    }

    return errors;
  }
}
