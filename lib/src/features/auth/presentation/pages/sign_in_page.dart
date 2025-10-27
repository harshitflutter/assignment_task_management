import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/core/styles/app_text_stryles.dart';
import 'package:task_management/src/features/auth/data/datasources/auth_data_sources.dart';
import 'package:task_management/src/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:task_management/src/features/auth/presentation/bloc/sign_in_bloc/sign_in_bloc.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_button.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_checkbox_widget.dart';
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
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: BlocConsumer<SignInBloc, SignInState>(
            listener: (context, state) {
              if (state is SignInSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.successMessage)));
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              }
              if (state is SignInFailedState) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }
            },
            builder: (context, state) {
              final bloc = context.read<SignInBloc>();
              return Container(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 20.w),
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: Form(
                  key: bloc.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 70.h),
                      //AppLogo
                      // Center(
                      //   child: Image.asset(
                      //     AppAssets.icApp,
                      //     height: 100.h,
                      //     width: 100.w,
                      //   ),
                      // ),
                      SizedBox(height: 50.h),

                      //heythereText
                      Text(
                        AppStrings.heythere,
                        style: AppTextStyles.primary400Size16,
                      ),
                      SizedBox(height: 5.h),

                      //LoginAnAccount
                      Text(
                        AppStrings.loginToAccount,
                        style: AppTextStyles.primary700Size20,
                      ),
                      SizedBox(height: 30.h),

                      //EmailField
                      CustomTestFormFieldWidget(
                        textEditingController: bloc.emailController,
                        hintText: AppStrings.email,
                        textHintStyle: AppTextStyles.hint400Size10,
                        prefixIcon: Padding(
                          padding: EdgeInsetsGeometry.only(
                            top: 3.h,
                            left: 20.w,
                            right: 5.w,
                          ),
                          child: Icon(
                            Icons.mail,
                            size: 18.h,
                            color: AppColors.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15.h),

                      //PwdField
                      CustomTestFormFieldWidget(
                        obscureText: bloc.isShowPassword,
                        textEditingController: bloc.passwordController,
                        hintText: AppStrings.password,
                        prefixIcon: Padding(
                          padding: EdgeInsetsGeometry.only(
                            top: 3.h,
                            left: 20.w,
                            right: 5.w,
                          ),
                          child: Icon(
                            Icons.lock,
                            size: 18.h,
                            color: AppColors.grey,
                          ),
                        ),
                        suffixIcon: InkWell(
                          onTap: () {
                            bloc.add(const ShowHidePasswordEvent());
                          },
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(
                              top: 3.h,
                              left: 15.w,
                              right: 20.w,
                            ),
                            child: Icon(
                              bloc.isShowPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 18.h,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter password";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15.h),

                      //AcceptPolicyText
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Checkbox
                          CustomCheckboxWidget(
                            value: bloc.isAgreeTermsCondition,
                            onChanged: (value) {
                              if (value == null) return;
                              bloc.add(
                                AgreeTermsConditionEvent(isAgree: value),
                              );
                            },
                          ),
                          SizedBox(width: 10.w),
                          //Text
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: AppStrings.byContinuingYouAccept,
                                  style: AppTextStyles.hint400Size10,
                                ),
                                TextSpan(
                                  text: AppStrings.privacyPolicy,
                                  style: AppTextStyles.hint400Size10.copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: AppStrings.and,
                                  style: AppTextStyles.hint400Size10,
                                ),
                                TextSpan(
                                  text: AppStrings.term,
                                  style: AppTextStyles.hint400Size10.copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: AppStrings.ofUse,
                                  style: AppTextStyles.hint400Size10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsetsGeometry.only(
              bottom: 50.h,
              right: 20.w,
              left: 20.w,
            ),
            child: BlocConsumer<SignInBloc, SignInState>(
              listener: (context, state) {},
              builder: (context, state) {
                final bloc = context.read<SignInBloc>();

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //SignInText
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: AppStrings.dontHaveAccount,
                            style: AppTextStyles.hint500Size12,
                          ),
                          TextSpan(
                            text: AppStrings.signUp,
                            style: AppTextStyles.primary600Size12,
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
                    ),
                    SizedBox(height: 10.h),

                    CustomButton(
                      isLoading: state is SignInLoadingState,
                      onTap: () {
                        bloc.add(const CallSignInEvent());
                      },
                      buttonLable: AppStrings.signIn,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
