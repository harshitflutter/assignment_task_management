import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_management/src/core/constants/app_assets.dart';
import 'package:task_management/src/core/constants/app_colors.dart';

class CustomCheckboxWidget extends StatelessWidget {
  final bool value;
  final double? size;
  final double rightPadding;
  final double boarderWidth;
  final double borderRadius;
  final Color bgColor;
  final Color borderColor;
  final Function(bool?) onChanged;

  const CustomCheckboxWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.size,
    this.rightPadding = 10,
    this.boarderWidth = 1,
    this.borderRadius = 2,
    this.bgColor = AppColors.white,
    this.borderColor = AppColors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: size ?? 16.w,
        height: size ?? 16.h,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: boarderWidth),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: value
            ? Padding(
                padding: EdgeInsetsGeometry.all(3.w),
                child: SvgPicture.asset(AppAssets.icCheck,
                    height: 10.h, width: 10.w, fit: BoxFit.fill),
              )
            : null,
      ),
    );
  }
}
