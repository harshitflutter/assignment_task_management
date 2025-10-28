import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';

class OfflineTag extends StatelessWidget {
  const OfflineTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.taskCardOverdue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.taskCardOverdue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 12.sp,
            color: AppColors.taskCardOverdue,
          ),
          SizedBox(width: 4.w),
          Text(
            'Offline',
            style: AppTextStyles.hint500Size10.copyWith(
              color: AppColors.taskCardOverdue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
