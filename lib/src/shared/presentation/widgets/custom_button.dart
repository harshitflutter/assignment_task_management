import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/styles/app_text_stryles.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String buttonLable;
  final void Function()? onTap;
  final TextStyle? textStyle;
  final TextStyle? loadingTextStyle;
  final BoxDecoration? boxDecoration;
  final bool isLoading;

  const CustomButton({
    super.key,
    this.height,
    this.width,
    this.isLoading = false,
    required this.buttonLable,
    this.boxDecoration,
    required this.onTap,
    this.textStyle,
    this.loadingTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width ?? double.infinity,
        height: height ?? 60.h,
        decoration: boxDecoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(99.r),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.buttonGrediant2,
                  AppColors.buttonGrediant1,
                ],
              ),
            ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.fourRotatingDots(
                    size: 24,
                    color: AppColors.white,
                  ),
                  SizedBox(width: 15.w),
                  Text(
                    AppStrings.loading,
                    style: loadingTextStyle ?? AppTextStyles.buttonTextStyle,
                  ),
                ],
              )
            : Text(buttonLable,
                style: textStyle ?? AppTextStyles.buttonTextStyle),
      ),
    );
  }
}
