import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_conflict.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';

/// Dialog for resolving individual task conflicts between local and cloud versions
class ConflictResolutionDialog extends StatefulWidget {
  final TaskConflict conflict;

  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
  });

  @override
  State<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  ConflictResolution? _selectedResolution;
  bool _isResolving = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConflictInfo(),
                    SizedBox(height: 12.h),
                    _buildVersionComparison(),
                    SizedBox(height: 12.h),
                    _buildResolutionOptions(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: AppColors.red,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.syncConflictDetected,
                  style: AppTextStyles.primary500Size14.copyWith(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppStrings.thisTaskWasModifiedOnBothDevices,
                  style: AppTextStyles.hint500Size12.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.conflictDetails,
            style: AppTextStyles.primary500Size14.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          _buildInfoRow(AppStrings.taskId, widget.conflict.taskId),
          _buildInfoRow(AppStrings.conflictType, _getConflictTypeText()),
          _buildInfoRow(AppStrings.detectedAt,
              _formatDateTime(widget.conflict.conflictDetectedAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: AppTextStyles.hint500Size12.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.hint500Size12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.versionComparison,
          style: AppTextStyles.primary500Size14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        _buildVersionCard(
          AppStrings.localVersion,
          widget.conflict.localVersion,
          AppColors.blue,
          Icons.phone_android_rounded,
        ),
        SizedBox(height: 8.h),
        _buildVersionCard(
          AppStrings.cloudVersion,
          widget.conflict.cloudVersion,
          AppColors.green,
          Icons.cloud_rounded,
        ),
      ],
    );
  }

  Widget _buildVersionCard(
      String title, TaskEntity task, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                title,
                style: AppTextStyles.primary500Size14.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Task details
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task title
                Text(
                  task.title,
                  style: AppTextStyles.hint500Size12.copyWith(
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    task.description,
                    style: AppTextStyles.hint500Size12.copyWith(
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 6.h),

                // Status and time row
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Updated: ${_formatDateTime(task.updatedAt)}',
                        style: AppTextStyles.hint500Size12.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chooseResolution,
          style: AppTextStyles.primary500Size14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        _buildResolutionOption(
          ConflictResolution.keepLocal,
          AppStrings.keepLocalVersion,
          AppStrings.useTheVersionFromThisDevice,
          Icons.phone_android_rounded,
          AppColors.blue,
        ),
        SizedBox(height: 6.h),
        _buildResolutionOption(
          ConflictResolution.keepCloud,
          AppStrings.keepCloudVersion,
          AppStrings.useTheVersionFromTheServer,
          Icons.cloud_rounded,
          AppColors.green,
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 14.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  AppStrings.theSelectedVersionWillBeSavedAndSynced,
                  style: AppTextStyles.primary500Size14.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResolutionOption(
    ConflictResolution resolution,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedResolution == resolution;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedResolution = resolution;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : AppColors.borderColor,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: AppColors.black,
                      size: 12.sp,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.primary500Size14.copyWith(
                      color: isSelected ? color : AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.primary400Size16.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isResolving || _selectedResolution == null
              ? null
              : _resolveConflict,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          child: _isResolving
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    color: AppColors.black,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  AppStrings.resolveConflict,
                  style: AppTextStyles.primary500Size14.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _resolveConflict() async {
    if (_selectedResolution == null) return;

    setState(() {
      _isResolving = true;
    });

    try {
      // Return the selected resolution
      if (mounted) {
        Navigator.of(context).pop(_selectedResolution);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.failedToResolveConflict}: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResolving = false;
        });
      }
    }
  }

  String _getConflictTypeText() {
    switch (widget.conflict.conflictType) {
      case ConflictType.bothModified:
        return AppStrings.bothVersionsModified;
      case ConflictType.localDeletedCloudModified:
        return AppStrings.localDeletedCloudModified;
      case ConflictType.cloudDeletedLocalModified:
        return AppStrings.cloudDeletedLocalModified;
      case ConflictType.bothDeleted:
        return AppStrings.bothVersionsDeleted;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.taskCardPending;
      case TaskStatus.completed:
        return AppColors.taskCardCompleted;
    }
  }
}
