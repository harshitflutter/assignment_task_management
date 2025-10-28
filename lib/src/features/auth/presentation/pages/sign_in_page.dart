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
import 'package:task_management/src/features/auth/presentation/bloc/sign_in_bloc/sign_in_bloc.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_test_form_field_widget.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInBloc>(
      create: (context) => SignInBloc(
        authRepo: AuthRepoImpl(
          AuthDataSources(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
      ),
      child: const SignInView(),
    );
  }
}

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.signInGradient1,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.signInGradient1,
              AppColors.signInGradient2,
              AppColors.signInGradient3,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: BlocConsumer<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state is SignInSuccessState) {
              _showSuccessSnackBar(context, state.successMessage);
              Navigator.pushReplacementNamed(context, AppRoutes.tasks);
            }
            if (state is SignInFailedState) {
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
                    SizedBox(height: 60.h),
                    _buildWelcomeSection(context),
                    SizedBox(height: 60.h),
                    _buildFormCard(context, state),
                    SizedBox(height: 32.h),
                    _buildSignUpLink(context),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      children: [
        // App Logo/Icon
        Container(
          width: 120.w,
          height: 120.h,
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
            Icons.task_alt_rounded,
            size: 60,
            color: AppColors.signInGradient1,
          ),
        ),

        SizedBox(height: 32.h),

        // Welcome Text
        Text(
          AppStrings.welcomeBack,
          style: AppTextStyles.headerTextStyle.copyWith(
            fontSize: 32.sp,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          AppStrings.signInToAccount,
          style: AppTextStyles.subtitleTextStyle.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context, SignInState state) {
    final currentState = state is SignInInitial
        ? state
        : state is SignInLoadingState
            ? SignInInitial(
                email: state.email,
                password: state.password,
                isPasswordVisible: state.isPasswordVisible,
                isLoading: true,
                animationsInitialized: state.animationsInitialized,
              )
            : const SignInInitial();
    return Container(
      padding: EdgeInsets.all(32.w),
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
          // Email Field
          _buildEmailField(context, currentState),

          SizedBox(height: 24.h),

          // Password Field
          _buildPasswordField(context, currentState),

          SizedBox(height: 32.h),

          // Sign In Button
          _buildSignInButton(context, currentState),
        ],
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, SignInInitial currentState) {
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
            color: AppColors.signInGradient1,
            size: 20,
          ),
          validator: (value) => context.read<SignInBloc>().validateEmail(value),
          onChanged: (value) {
            context.read<SignInBloc>().add(SignInEmailChangedEvent(value));
          },
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.signInGradient1,
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

  Widget _buildPasswordField(BuildContext context, SignInInitial currentState) {
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
          hintText: AppStrings.enterPassword,
          obscureText: !currentState.isPasswordVisible,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppColors.signInGradient1,
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
                  .read<SignInBloc>()
                  .add(const SignInPasswordVisibilityToggledEvent());
            },
          ),
          validator: (value) =>
              context.read<SignInBloc>().validatePassword(value),
          onChanged: (value) {
            context.read<SignInBloc>().add(SignInPasswordChangedEvent(value));
          },
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.signInGradient1,
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

  Widget _buildSignInButton(BuildContext context, SignInInitial currentState) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          colors: [
            AppColors.signInGradient1,
            AppColors.signInGradient2,
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
              : () => _handleSignIn(context, currentState, formKey),
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
                    AppStrings.signIn,
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

  Widget _buildSignUpLink(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: AppStrings.dontHaveAccount,
            style: AppTextStyles.subtitleTextStyle.copyWith(
              fontSize: 16.sp,
            ),
          ),
          WidgetSpan(child: SizedBox(width: 4.w)),
          TextSpan(
            text: AppStrings.signUp,
            style: AppTextStyles.buttonTextStyle.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.signUp,
                );
              },
          ),
        ],
      ),
    );
  }

  void _handleSignIn(BuildContext context, SignInInitial currentState,
      GlobalKey<FormState> formKey) {
    final signInBloc = context.read<SignInBloc>();

    // Validate form fields first
    if (formKey.currentState?.validate() ?? false) {
      // If form is valid, proceed with sign in using controller values
      signInBloc.add(SignInRequestedEvent(
        email: emailController.text.trim(),
        password: passwordController.text,
        agreeTerms: true,
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
