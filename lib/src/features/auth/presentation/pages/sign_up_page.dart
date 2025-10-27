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
import 'package:task_management/src/features/auth/presentation/bloc/sign_up_bloc/sign_up_bloc.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_button.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_checkbox_widget.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_test_form_field_widget.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpBloc(
        authRepo: AuthRepoImpl(
          AuthDataSources(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
      ),
      child: Scaffold(
        body: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state is SignUpFailedState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.errorMessage)));
            }
            if (state is SignUpSuccessState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.successMessage)));

              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
          builder: (context, state) {
            final bloc = context.read<SignUpBloc>();
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.grediant1, AppColors.grediant2],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20.w),
                  child: Form(
                    key: bloc.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50.h),
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

                        //createAccount
                        Text(
                          AppStrings.createAccount,
                          style: AppTextStyles.primary700Size20,
                        ),
                        SizedBox(height: 30.h),

                        //fullName
                        CustomTestFormFieldWidget(
                          textEditingController: bloc.fullNameController,
                          hintText: AppStrings.fullName,
                          prefixIcon: Padding(
                            padding: EdgeInsetsGeometry.only(
                              top: 3.h,
                              left: 20.w,
                              right: 5.w,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 18.h,
                              color: AppColors.grey,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter full name";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.h),

                        //Username
                        CustomTestFormFieldWidget(
                          textEditingController: bloc.usernameController,
                          hintText: AppStrings.userName,
                          prefixIcon: Padding(
                            padding: EdgeInsetsGeometry.only(
                              top: 3.h,
                              left: 20.w,
                              right: 5.w,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 18.h,
                              color: AppColors.grey,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter username";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.h),

                        //EmailFiled
                        CustomTestFormFieldWidget(
                          textEditingController: bloc.emailController,
                          hintText: AppStrings.email,
                          textInputType: TextInputType.emailAddress,
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
                              return "Please enter email address";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.h),

                        //PasswordField
                        CustomTestFormFieldWidget(
                          textEditingController: bloc.passwordController,
                          hintText: AppStrings.password,
                          obscureText: bloc.isShowPassword,
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
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
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

                        //ConfirmPasswordField
                        CustomTestFormFieldWidget(
                          textEditingController: bloc.confirmPasswordController,
                          obscureText: bloc.isShowConfirmPassword,
                          hintText: AppStrings.confirmPassword,
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
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              bloc.add(const ShowHideConfirmPasswordEvent());
                            },
                            child: Padding(
                              padding: EdgeInsetsGeometry.only(
                                top: 3.h,
                                left: 15.w,
                                right: 20.w,
                              ),
                              child: Icon(
                                bloc.isShowConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 18.h,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter confirm password";
                            } else if (value != bloc.passwordController.text) {
                              return "Password & confirm password not match";
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
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsetsGeometry.only(
            bottom: 50.h,
            right: 20.w,
            left: 20.w,
          ),
          child: BlocConsumer<SignUpBloc, SignUpState>(
            listener: (context, state) {},
            builder: (context, state) {
              final bloc = context.read<SignUpBloc>();
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
                          text: AppStrings.signIn,
                          style: AppTextStyles.primary600Size12,
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
                  ),
                  SizedBox(height: 10.h),
                  CustomButton(
                    onTap: () {
                      bloc.add(const CallSignUpEvent());
                    },
                    buttonLable: AppStrings.register,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
