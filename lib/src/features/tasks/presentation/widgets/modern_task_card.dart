import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';

class ModernTaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ModernTaskCard({
    super.key,
    required this.task,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !isCompleted;
    final isDueToday = task.dueDate.day == DateTime.now().day &&
        task.dueDate.month == DateTime.now().month &&
        task.dueDate.year == DateTime.now().year;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.horizontal,
        background: _buildSwipeBackground(
          context,
          isLeft: true,
          icon: Icons.edit_rounded,
          color: AppColors.taskCardPrimary,
          label: 'Edit',
        ),
        secondaryBackground: _buildSwipeBackground(
          context,
          isLeft: false,
          icon: Icons.delete_rounded,
          color: AppColors.taskCardOverdue,
          label: 'Delete',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onEdit();
            return false;
          } else {
            return await _showDeleteConfirmation(context);
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onDelete();
          }
        },
        child: _buildCompactCreativeCard(
            context, isCompleted, isOverdue, isDueToday),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required bool isLeft,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isLeft) ...[
            SizedBox(width: 16.w),
            Icon(icon, color: AppColors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.buttonTextStyle.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Text(
              label,
              style: AppTextStyles.buttonTextStyle.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(icon, color: AppColors.white, size: 18.sp),
            SizedBox(width: 16.w),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactCreativeCard(
    BuildContext context,
    bool isCompleted,
    bool isOverdue,
    bool isDueToday,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.white,
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.taskDetail,
              arguments: task.id,
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompactHeader(
                    context, isCompleted, isOverdue, isDueToday),
                SizedBox(height: 8.h),
                _buildCompactContent(
                    context, isCompleted, isOverdue, isDueToday),
                if (task.attachmentPath != null) ...[
                  SizedBox(height: 8.h),
                  _buildCompactAttachment(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(
    BuildContext context,
    bool isCompleted,
    bool isOverdue,
    bool isDueToday,
  ) {
    return Row(
      children: [
        // Checkbox for status toggle
        GestureDetector(
          onTap: onToggleStatus,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? _getStatusColor(isCompleted, isOverdue, isDueToday)
                  : AppColors.white,
              border: Border.all(
                color: isCompleted
                    ? _getStatusColor(isCompleted, isOverdue, isDueToday)
                    : AppColors.grey.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 14.sp,
                  )
                : null,
          ),
        ),
        SizedBox(width: 8.w),
        // Task title
        Expanded(
          child: Text(
            task.title,
            style: AppTextStyles.primary700Size24.copyWith(
              color: AppColors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.grey,
              decorationThickness: 1.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Due date badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.grey.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            _formatDate(task.dueDate),
            style: AppTextStyles.hint500Size12.copyWith(
              color: AppColors.grey,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    bool isCompleted,
    bool isOverdue,
    bool isDueToday,
  ) {
    return Row(
      children: [
        // Description
        Expanded(
          child: Text(
            task.description.isNotEmpty ? task.description : 'No description',
            style: AppTextStyles.primary400Size16.copyWith(
              color: AppColors.grey,
              fontSize: 13.sp,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        // Status badge with tap hint
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _getStatusColor(isCompleted, isOverdue, isDueToday),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: _getStatusColor(isCompleted, isOverdue, isDueToday)
                  .withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted ? Icons.check_rounded : Icons.schedule_rounded,
                color: AppColors.white,
                size: 12.sp,
              ),
              SizedBox(width: 3.w),
              Text(
                isCompleted ? 'Done' : 'Pending',
                style: AppTextStyles.hint500Size12.copyWith(
                  color: AppColors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactAttachment(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.taskCardPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.taskCardPrimary.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file_rounded,
            color: AppColors.taskCardPrimary,
            size: 12.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            task.attachmentName ?? 'Attachment',
            style: AppTextStyles.hint500Size12.copyWith(
              color: AppColors.taskCardPrimary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Color helper methods

  Color _getStatusColor(bool isCompleted, bool isOverdue, bool isDueToday) {
    if (isCompleted) {
      return AppColors.taskCardCompleted;
    } else if (isOverdue) {
      return AppColors.taskCardOverdue;
    } else if (isDueToday) {
      return AppColors.taskCardDueToday;
    } else {
      return AppColors.taskCardPrimary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
