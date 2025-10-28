import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:task_management/src/core/constants/app_assets.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                AppAssets.lottieInternet,
                width: 150.w,
                height: 150.h,
                fit: BoxFit.fill,
              ),
              SizedBox(height: 15.h),
              Text(
                AppStrings.noInternet,
                style: AppTextStyles.primary700Size20,
              ),
              SizedBox(height: 8.h),
              Text(
                AppStrings.pleaseCheckNetwork,
                textAlign: TextAlign.center,
                style: AppTextStyles.hint400Size10.copyWith(fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
