part of 'sign_up_bloc.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool agreeTerms;
  final bool isLoading;
  final bool animationsInitialized;

  const SignUpInitial({
    this.fullName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.agreeTerms = false,
    this.isLoading = false,
    this.animationsInitialized = false,
  });

  @override
  List<Object> get props => [
        fullName,
        username,
        email,
        password,
        confirmPassword,
        isPasswordVisible,
        isConfirmPasswordVisible,
        agreeTerms,
        isLoading,
        animationsInitialized,
      ];

  SignUpInitial copyWith({
    String? fullName,
    String? username,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? agreeTerms,
    bool? isLoading,
    bool? animationsInitialized,
  }) {
    return SignUpInitial(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      agreeTerms: agreeTerms ?? this.agreeTerms,
      isLoading: isLoading ?? this.isLoading,
      animationsInitialized:
          animationsInitialized ?? this.animationsInitialized,
    );
  }
}

class SignUpLoadingState extends SignUpState {
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool agreeTerms;
  final bool animationsInitialized;

  const SignUpLoadingState({
    this.fullName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.agreeTerms = false,
    this.animationsInitialized = false,
  });

  @override
  List<Object> get props => [
        fullName,
        username,
        email,
        password,
        confirmPassword,
        isPasswordVisible,
        isConfirmPasswordVisible,
        agreeTerms,
        animationsInitialized,
      ];
}

class SignUpSuccessState extends SignUpState {
  final String successMessage;

  const SignUpSuccessState({required this.successMessage});
  @override
  List<Object> get props => [successMessage];
}

class SignUpFailedState extends SignUpState {
  final String errorMessage;

  const SignUpFailedState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class SignUpPasswordVisibilityState extends SignUpState {
  final bool isPasswordVisible;

  const SignUpPasswordVisibilityState({required this.isPasswordVisible});
  @override
  List<Object> get props => [isPasswordVisible];
}

class SignUpConfirmPasswordVisibilityState extends SignUpState {
  final bool isConfirmPasswordVisible;

  const SignUpConfirmPasswordVisibilityState(
      {required this.isConfirmPasswordVisible});
  @override
  List<Object> get props => [isConfirmPasswordVisible];
}

class SignUpValidationErrorState extends SignUpState {
  final Map<String, String> fieldErrors;

  const SignUpValidationErrorState({required this.fieldErrors});
  @override
  List<Object> get props => [fieldErrors];
}

class SignUpFormValidState extends SignUpState {}
