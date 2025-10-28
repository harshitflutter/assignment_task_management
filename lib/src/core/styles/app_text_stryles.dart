import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';

class AppTextStyles {
  static TextStyle primary700Size20 = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.purple,
  );

  static TextStyle hint400Size10 = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  static TextStyle primary400Size16 = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static TextStyle fieldTextStyle = TextStyle(
    color: AppColors.black,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle hint500Size12 = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
  );

  static TextStyle primary600Size12 = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.purple,
  );

  ///ButtonTextStyle
  static TextStyle buttonTextStyle = TextStyle(
    color: AppColors.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
  );
}
