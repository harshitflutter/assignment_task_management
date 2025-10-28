import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/auth/data/datasources/auth_data_sources.dart';
import 'package:task_management/src/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:task_management/src/features/auth/presentation/bloc/sign_up_bloc/sign_up_bloc.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_checkbox_widget.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_test_form_field_widget.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpBloc>(
      create: (context) => SignUpBloc(
        authRepo: AuthRepoImpl(
          AuthDataSources(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
      ),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController fullNameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.signUpGradient1,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.signUpGradient1,
              AppColors.signUpGradient2,
              AppColors.signUpGradient3,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<SignUpBloc, SignUpState>(
            listener: (context, state) {
              if (state is SignUpSuccessState) {
                _showSuccessSnackBar(context, state.successMessage);
                Navigator.pushReplacementNamed(context, AppRoutes.tasks);
              }
              if (state is SignUpFailedState) {
                _showErrorSnackBar(context, state.errorMessage);
              }
              // Validation errors are handled by form field validators, no snackbar needed
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      _buildWelcomeSection(context),
                      SizedBox(height: 40.h),
                      _buildFormCard(context, state),
                      SizedBox(height: 32.h),
                      _buildSignInLink(context),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      children: [
        // App Logo/Icon
        Container(
          width: 100.w,
          height: 100.h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.white,
                AppColors.formBackground,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.formShadow,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 50,
            color: AppColors.signUpIconColor,
          ),
        ),

        SizedBox(height: 24.h),

        // Welcome Text
        Text(
          AppStrings.createAccount,
          style: AppTextStyles.headerTextStyle.copyWith(
            fontSize: 28.sp,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          AppStrings.signUpDescription,
          style: AppTextStyles.subtitleTextStyle.copyWith(
            fontSize: 16.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context, SignUpState state) {
    final currentState = state is SignUpInitial
        ? state
        : state is SignUpLoadingState
            ? SignUpInitial(
                fullName: state.fullName,
                username: state.username,
                email: state.email,
                password: state.password,
                confirmPassword: state.confirmPassword,
                isPasswordVisible: state.isPasswordVisible,
                isConfirmPasswordVisible: state.isConfirmPasswordVisible,
                agreeTerms: state.agreeTerms,
                isLoading: true,
                animationsInitialized: state.animationsInitialized,
              )
            : const SignUpInitial();

    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.formShadow,
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          _buildFullNameField(context, currentState),

          SizedBox(height: 20.h),

          // Username Field
          _buildUsernameField(context, currentState),

          SizedBox(height: 20.h),

          // Email Field
          _buildEmailField(context, currentState),

          SizedBox(height: 20.h),

          // Password Field
          _buildPasswordField(context, currentState),

          SizedBox(height: 20.h),

          // Confirm Password Field
          _buildConfirmPasswordField(context, currentState),

          SizedBox(height: 24.h),

          // Terms and Conditions
          _buildTermsSection(context, currentState),

          SizedBox(height: 32.h),

          // Sign Up Button
          _buildSignUpButton(context, currentState),
        ],
      ),
    );
  }

  Widget _buildFullNameField(BuildContext context, SignUpInitial currentState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.fullName,
          style: AppTextStyles.primary500Size14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTestFormFieldWidget(
          textEditingController: fullNameController,
          hintText: AppStrings.enterFullName,
          prefixIcon: const Icon(
            Icons.person_outline,
            color: AppColors.signUpIconColor,
            size: 20,
          ),
          validator: (value) =>
              context.read<SignUpBloc>().validateFullName(value),
          onChanged: (value) {
            context.read<SignUpBloc>().add(SignUpFullNameChangedEvent(value));
          },
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.signUpIconColor,
              width: 2,
            ),
          ),
          enableBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.red,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context, SignUpInitial currentState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.userName,
          style: AppTextStyles.primary500Size14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTestFormFieldWidget(
          textEditingController: usernameController,
          hintText: AppStrings.chooseUsername,
          prefixIcon: const Icon(
            Icons.alternate_email,
            color: AppColors.signUpIconColor,
            size: 20,
          ),
          validator: (value) =>
              context.read<SignUpBloc>().validateUsername(value),
          onChanged: (value) {
            context.read<SignUpBloc>().add(SignUpUsernameChangedEvent(value));
          },
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.signUpIconColor,
              width: 2,
            ),
          ),
          enableBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.red,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, SignUpInitial currentState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.email,
          style: AppTextStyles.primary500Size14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTestFormFieldWidget(
          textEditingController: emailController,
          hintText: AppStrings.enterEmail,
          textInputType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: AppColors.signUpIconColor,
            size: 20,
          ),
          validator: (value) => context.read<SignUpBloc>().validateEmail(value),
          onChanged: (value) {
            context.read<SignUpBloc>().add(SignUpEmailChangedEvent(value));
          },
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.signUpIconColor,
              width: 2,
            ),
          ),
          enableBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.red,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, SignUpInitial currentState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.password,
          style: AppTextStyles.primary500Size14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTestFormFieldWidget(
          textEditingController: passwordController,
          hintText: AppStrings.createPassword,
          obscureText: !currentState.isPasswordVisible,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppColors.signUpIconColor,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              currentState.isPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.grey,
            ),
            onPressed: () {
              context
                  .read<SignUpBloc>()
                  .add(const SignUpPasswordVisibilityToggledEvent());
            },
          ),
          validator: (value) =>
              context.read<SignUpBloc>().validatePassword(value),
          onChanged: (value) {
            context.read<SignUpBloc>().add(SignUpPasswordChangedEvent(value));
          },
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.signUpIconColor,
              width: 2,
            ),
          ),
          enableBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.red,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(
      BuildContext context, SignUpInitial currentState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.confirmPassword,
          style: AppTextStyles.primary500Size14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTestFormFieldWidget(
          textEditingController: confirmPasswordController,
          hintText: AppStrings.confirmPasswordHint,
          obscureText: !currentState.isConfirmPasswordVisible,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppColors.signUpIconColor,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              currentState.isConfirmPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.grey,
            ),
            onPressed: () {
              context
                  .read<SignUpBloc>()
                  .add(const SignUpConfirmPasswordVisibilityToggledEvent());
            },
          ),
          validator: (value) => context
              .read<SignUpBloc>()
              .validateConfirmPassword(value, passwordController.text),
          onChanged: (value) {
            context
                .read<SignUpBloc>()
                .add(SignUpConfirmPasswordChangedEvent(value));
          },
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.signUpIconColor,
              width: 2,
            ),
          ),
          enableBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.red,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection(BuildContext context, SignUpInitial currentState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCheckboxWidget(
          value: currentState.agreeTerms,
          onChanged: (value) {
            context
                .read<SignUpBloc>()
                .add(SignUpTermsChangedEvent(value ?? false));
          },
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: AppStrings.iAgreeToThe,
                  style: AppTextStyles.hint400Size14.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
                TextSpan(
                  text: AppStrings.termsOfService,
                  style: AppTextStyles.hint400Size14.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.signUpLinkColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: AppStrings.and,
                  style: AppTextStyles.hint400Size14.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
                TextSpan(
                  text: AppStrings.privacyPolicy,
                  style: AppTextStyles.hint400Size14.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.signUpLinkColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: AppStrings.alreadyHaveAccount,
            style: AppTextStyles.subtitleTextStyle.copyWith(
              fontSize: 16.sp,
            ),
          ),
          WidgetSpan(child: SizedBox(width: 4.w)),
          TextSpan(
            text: AppStrings.signIn,
            style: AppTextStyles.buttonTextStyle.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.signIn,
                );
              },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context, SignUpInitial currentState) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          colors: [
            AppColors.signUpGradient2,
            AppColors.signUpGradient3,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.buttonShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: currentState.isLoading
              ? null
              : () => _handleSignUp(context, currentState, formKey),
          child: Container(
            alignment: Alignment.center,
            child: currentState.isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    AppStrings.createAccountButton,
                    style: AppTextStyles.buttonTextStyle.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp(BuildContext context, SignUpInitial currentState,
      GlobalKey<FormState> formKey) {
    final signUpBloc = context.read<SignUpBloc>();

    // Validate form fields first
    if (formKey.currentState?.validate() ?? false) {
      // If form is valid, proceed with sign up
      signUpBloc.add(SignUpRequestedEvent(
        fullName: fullNameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        agreeTerms: currentState.agreeTerms,
      ));
    }
    // If form validation fails, the individual field validators will show errors
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
