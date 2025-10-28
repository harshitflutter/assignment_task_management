part of 'sign_in_bloc.dart';

sealed class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isLoading;
  final bool animationsInitialized;

  const SignInInitial({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.animationsInitialized = false,
  });

  @override
  List<Object> get props => [
        email,
        password,
        isPasswordVisible,
        isLoading,
        animationsInitialized,
      ];

  SignInInitial copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    bool? animationsInitialized,
  }) {
    return SignInInitial(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      animationsInitialized:
          animationsInitialized ?? this.animationsInitialized,
    );
  }
}

class SignInLoadingState extends SignInState {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool animationsInitialized;

  const SignInLoadingState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.animationsInitialized = false,
  });

  @override
  List<Object> get props => [
        email,
        password,
        isPasswordVisible,
        animationsInitialized,
      ];
}

class SignInSuccessState extends SignInState {
  final String successMessage;

  const SignInSuccessState({required this.successMessage});
  @override
  List<Object> get props => [successMessage];
}

class SignInFailedState extends SignInState {
  final String errorMessage;

  const SignInFailedState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class SignInPasswordVisibilityState extends SignInState {
  final bool isPasswordVisible;

  const SignInPasswordVisibilityState({required this.isPasswordVisible});
  @override
  List<Object> get props => [isPasswordVisible];
}

class SignInValidationErrorState extends SignInState {
  final Map<String, String> fieldErrors;

  const SignInValidationErrorState({required this.fieldErrors});
  @override
  List<Object> get props => [fieldErrors];
}

class SignInFormValidState extends SignInState {}
