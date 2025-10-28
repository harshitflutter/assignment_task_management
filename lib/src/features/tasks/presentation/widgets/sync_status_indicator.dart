import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';

class SyncStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getBackgroundColor().withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            SizedBox(width: 6.w),
            _buildStatusText(),
            if (isSyncing) ...[
              SizedBox(width: 6.w),
              SizedBox(
                width: 10.w,
                height: 10.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (isSyncing) {
      return Icon(
        Icons.sync,
        size: 14.sp,
        color: AppColors.white,
      );
    } else if (isOnline) {
      return Icon(
        Icons.cloud_done,
        size: 14.sp,
        color: AppColors.white,
      );
    } else {
      return Icon(
        Icons.cloud_off,
        size: 14.sp,
        color: AppColors.white,
      );
    }
  }

  Widget _buildStatusText() {
    if (isSyncing) {
      return Text(
        AppStrings.syncing,
        style: AppTextStyles.hint500Size12.copyWith(
          color: AppColors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (isOnline) {
      if (lastSyncedAt != null) {
        final timeAgo = _getTimeAgo(lastSyncedAt!);
        return Text(
          '${AppStrings.synced} $timeAgo',
          style: AppTextStyles.hint500Size12.copyWith(
            color: AppColors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        );
      } else {
        return Text(
          AppStrings.online,
          style: AppTextStyles.hint500Size12.copyWith(
            color: AppColors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        );
      }
    } else {
      return Text(
        AppStrings.offline,
        style: AppTextStyles.hint500Size12.copyWith(
          color: AppColors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  Color _getBackgroundColor() {
    if (isSyncing) {
      return AppColors.taskCardPending;
    } else if (isOnline) {
      return AppColors.taskCardCompleted;
    } else {
      return AppColors.taskCardOverdue;
    }
  }

  Color _getBorderColor() {
    if (isSyncing) {
      return AppColors.taskCardPending.withOpacity(0.8);
    } else if (isOnline) {
      return AppColors.taskCardCompleted.withOpacity(0.8);
    } else {
      return AppColors.taskCardOverdue.withOpacity(0.8);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${AppStrings.minutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${AppStrings.hoursAgo}';
    } else {
      return '${difference.inDays} ${AppStrings.daysAgo}';
    }
  }
}
