import 'package:flutter/material.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';

/// SnackbarUtils provides consistent SnackBar presentations across the app.
class SnackbarUtils {
  /// Shows a success snackbar with a check icon and green background.
  static void showSuccess(BuildContext context, String message) {
    _show(context,
        message: message,
        backgroundColor: AppColors.green,
        leading: const Icon(Icons.check_circle, color: AppColors.white));
  }

  /// Shows an error snackbar with an error icon and red background.
  static void showError(BuildContext context, String message) {
    _show(context,
        message: message,
        backgroundColor: AppColors.red,
        leading: const Icon(Icons.error, color: AppColors.white));
  }

  /// Shows an informational snackbar with default styling.
  static void showInfo(BuildContext context, String message) {
    _show(context,
        message: message,
        backgroundColor: Colors.black87,
        leading: const Icon(Icons.info, color: AppColors.white));
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Widget leading,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            leading,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.primary400Size16.copyWith(
                  color: AppColors.white,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
