import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';

class AppTextStyles {
  // Primary Text Styles
  static TextStyle primary400Size16 = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static TextStyle primary500Size14 = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle primary600Size18 = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle primary700Size24 = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );

  // Hint Text Styles
  static TextStyle hint400Size10 = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    color: Colors.grey[600],
  );

  static TextStyle hint500Size12 = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: Colors.grey[600],
  );

  static TextStyle hint400Size14 = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: Colors.grey[600],
  );

  // Field Text Styles
  static TextStyle fieldTextStyle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  // Button Text Styles
  static TextStyle buttonTextStyle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle buttonTextStyleSecondary = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.grey[600],
  );

  // Header Text Styles
  static TextStyle headerTextStyle = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle subtitleTextStyle = TextStyle(
    fontSize: 14.sp,
    color: Colors.white.withOpacity(0.8),
  );

  // Drawer Text Styles
  static TextStyle drawerHeaderTextStyle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Additional Text Styles
  static TextStyle primary700Size20 = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.purple,
  );

  static TextStyle primary600Size12 = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.purple,
  );

  static TextStyle hint500Size10 = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: Colors.grey[600],
  );

  static TextStyle drawerSubtitleTextStyle = TextStyle(
    fontSize: 14.sp,
    color: Colors.white70,
  );

  // Dialog Text Styles
  static TextStyle dialogTitleTextStyle = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle dialogSubtitleTextStyle = TextStyle(
    fontSize: 14.sp,
    color: Colors.white.withOpacity(0.8),
  );

  // Info Card Text Styles
  static TextStyle infoCardTitleTextStyle = TextStyle(
    fontSize: 12.sp,
    color: Colors.grey[600],
    fontWeight: FontWeight.w500,
  );

  static TextStyle infoCardValueTextStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
}
