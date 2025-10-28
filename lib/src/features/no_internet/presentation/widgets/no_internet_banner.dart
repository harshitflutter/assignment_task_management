import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/features/no_internet/data/no_internet_cubit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetCubit, InternetConnectionStatus?>(
      builder: (context, status) {
        // Only show banner when offline
        if (status != InternetConnectionStatus.disconnected) {
          return const SizedBox.shrink();
        }

        return Material(
          child: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Offline Icon
                  Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.red,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),

                  // Message
                  Expanded(
                    child: Text(
                      AppStrings.noInternet,
                      style: AppTextStyles.primary500Size14.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Retry Button
                  GestureDetector(
                    onTap: () => _retryConnection(context),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Retry',
                        style: AppTextStyles.hint500Size12.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _retryConnection(BuildContext context) async {
    try {
      // Check internet connection
      final hasConnection =
          await InternetConnectionChecker.instance.hasConnection;

      if (hasConnection) {
        // Internet is back, the banner will automatically hide via Bloc
        return;
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Still no internet connection'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error checking connection'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
