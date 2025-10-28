import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/core/utils/file_type_utils.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/offline_tag.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/sync_status_indicator.dart';
import 'package:task_management/src/shared/presentation/widgets/image_viewer.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildModernAppBar(context),
      body: SafeArea(
        child: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TaskLoaded && state.tasks.isNotEmpty) {
              final task = state.tasks.firstWhere(
                (t) => t.id == taskId,
                orElse: () => state.tasks.first,
              );

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTaskHeader(context, task),
                    _buildTaskContent(context, task),
                    _buildTaskActions(context, task),
                  ],
                ),
              );
            } else if (state is TaskLoading) {
              return _buildLoadingState();
            } else {
              return _buildErrorState();
            }
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.drawerGradient1,
              AppColors.drawerGradient2,
            ],
          ),
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.white,
            size: 18.sp,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      title: Text(
        'Task Details',
        style: AppTextStyles.primary700Size24.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        // Sync Status Indicator - Only show when there are tasks
        BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TaskLoaded && state.tasks.isNotEmpty) {
              return Container(
                margin: EdgeInsets.only(right: 8.w, top: 8.r, bottom: 8.r),
                child: SyncStatusIndicator(
                  isOnline: state.isOnline,
                  isSyncing: state.isSyncing,
                  lastSyncedAt: state.lastSyncedAt,
                  onTap: () => _syncTasks(context),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Edit Button
        Container(
          margin: EdgeInsets.only(right: 16.w, top: 8.r, bottom: 8.r),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addTask,
                arguments: taskId,
              );
            },
            icon: Icon(
              Icons.edit_rounded,
              color: AppColors.white,
              size: 18.sp,
            ),
            padding: EdgeInsets.all(8.r),
            tooltip: 'Edit Task',
          ),
        ),
      ],
    );
  }

  Widget _buildTaskHeader(BuildContext context, TaskEntity task) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !isCompleted;
    final isDueToday = task.dueDate.day == DateTime.now().day &&
        task.dueDate.month == DateTime.now().month &&
        task.dueDate.year == DateTime.now().year;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status checkbox
              GestureDetector(
                onTap: () {
                  context.read<TaskCubit>().toggleTaskStatus(
                        task.id,
                        task.userId,
                      );
                },
                child: Container(
                  width: 24.w,
                  height: 24.w,
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
                          size: 16.sp,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              // Task title
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.primary700Size24.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.grey,
                    decorationThickness: 2,
                  ),
                ),
              ),
              // Offline tag
              if (task.isOffline) ...[
                SizedBox(width: 12.w),
                const OfflineTag(),
              ],
            ],
          ),
          SizedBox(height: 16.h),
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _getStatusColor(isCompleted, isOverdue, isDueToday),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_rounded : Icons.schedule_rounded,
                  color: AppColors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  isCompleted ? 'Completed' : 'Pending',
                  style: AppTextStyles.buttonTextStyle.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskContent(BuildContext context, TaskEntity task) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (task.description.isNotEmpty) ...[
            Text(
              'Description',
              style: AppTextStyles.primary600Size18.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                task.description,
                style: AppTextStyles.primary400Size16.copyWith(
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // Due Date
          Text(
            'Due Date',
            style: AppTextStyles.primary600Size18.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: _getDueDateColor(task).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _getDueDateColor(task).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: _getDueDateColor(task),
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  _formatDate(task.dueDate),
                  style: AppTextStyles.primary500Size14.copyWith(
                    fontSize: 14.sp,
                    color: _getDueDateColor(task),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Attachment Section
          if (task.attachmentPath != null) ...[
            SizedBox(height: 20.h),
            Text(
              'Attachment',
              style: AppTextStyles.primary600Size18.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            _buildAttachmentSection(context, task),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentSection(BuildContext context, TaskEntity task) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.taskCardPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.taskCardPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Show image if it's an image file
          if (FileTypeUtils.isImage(task.attachmentPath) ||
              FileTypeUtils.isImageByAttachmentName(task.attachmentName)) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: ImageViewer(
                imagePath: task.attachmentPath!,
                imageName: task.attachmentName,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                showFullScreenOnTap: true,
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // File info
          GestureDetector(
            onTap: () => _previewFile(context, task),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.taskCardPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    FileTypeUtils.getFileIcon(task.attachmentName ?? ''),
                    color: AppColors.taskCardPrimary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.attachmentName ?? 'Unknown file',
                        style: AppTextStyles.primary600Size18.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getPreviewText(task),
                        style: AppTextStyles.hint500Size12.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: AppColors.taskCardPrimary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskActions(BuildContext context, TaskEntity task) {
    final isCompleted = task.status == TaskStatus.completed;

    return Container(
      margin: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<TaskCubit>().toggleTaskStatus(
                      task.id,
                      task.userId,
                    );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [
                            AppColors.taskCardDueToday,
                            AppColors.taskCardDueToday.withOpacity(0.8)
                          ]
                        : [
                            AppColors.taskCardCompleted,
                            AppColors.taskCardCompleted.withOpacity(0.8)
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted
                              ? AppColors.taskCardDueToday
                              : AppColors.taskCardCompleted)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.undo_rounded
                          : Icons.check_circle_rounded,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isCompleted ? 'Mark as Pending' : 'Mark as Complete',
                      style: AppTextStyles.buttonTextStyle.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _showDeleteConfirmation(context, task);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.taskCardOverdue,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.taskCardOverdue.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_rounded,
                      color: AppColors.taskCardOverdue,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppStrings.delete,
                      style: AppTextStyles.buttonTextStyleSecondary.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.taskCardOverdue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.taskCardPrimary,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.loadingTaskDetails,
            style: AppTextStyles.primary400Size16.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.taskCardOverdue,
            size: 64.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'Task not found',
            style: AppTextStyles.primary600Size18.copyWith(
              fontSize: 18.sp,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.theTaskYouAreLookingForDoesNotExist,
            style: AppTextStyles.primary400Size16.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
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

  Color _getDueDateColor(TaskEntity task) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !isCompleted;
    final isDueToday = task.dueDate.day == DateTime.now().day &&
        task.dueDate.month == DateTime.now().month &&
        task.dueDate.year == DateTime.now().year;

    if (isCompleted) {
      return AppColors.taskCardCompleted;
    } else if (isOverdue) {
      return AppColors.taskCardOverdue;
    } else if (isDueToday) {
      return AppColors.taskCardDueToday;
    } else {
      return AppColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return AppStrings.today;
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return AppStrings.tomorrow;
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return AppStrings.yesterday;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteConfirmation(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.deleteTask,
            style: AppTextStyles.primary600Size18,
          ),
          content: Text(
            '${AppStrings.areYouSureDeleteTask} "${task.title}"? ${AppStrings.actionCannotBeUndone}.',
            style: AppTextStyles.primary400Size16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TaskCubit>().deleteTask(task.id, task.userId);
                Navigator.pop(context); // Go back to tasks list
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _getPreviewText(TaskEntity task) {
    if (task.attachmentPath == null) return 'No attachment';

    final isImageFile = FileTypeUtils.isImage(task.attachmentPath) ||
        FileTypeUtils.isImageByAttachmentName(task.attachmentName);

    if (isImageFile) {
      return 'Tap to view full screen';
    } else {
      return 'Tap to open file';
    }
  }

  Future<void> _previewFile(BuildContext context, TaskEntity task) async {
    if (task.attachmentPath == null) return;

    try {
      final isImageFile = FileTypeUtils.isImage(task.attachmentPath) ||
          FileTypeUtils.isImageByAttachmentName(task.attachmentName);

      if (isImageFile) {
        // For images, show full screen viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageViewer(
              imagePath: task.attachmentPath!,
              imageName: task.attachmentName,
            ),
          ),
        );
      } else {
        // For non-image files, use open_file package
        if (task.attachmentPath!.startsWith('https://')) {
          // For Firebase Storage URLs, download and open
          await _openFirebaseFile(context, task);
        } else {
          // For local files, open directly
          final result = await OpenFile.open(task.attachmentPath!);
          if (result.type != ResultType.done && context.mounted) {
            _showErrorSnackBar(
                context, 'Failed to open file: ${result.message}');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to preview file: $e');
      }
    }
  }

  Future<void> _openFirebaseFile(BuildContext context, TaskEntity task) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading file from cloud storage...'),
            backgroundColor: AppColors.purple,
          ),
        );
      }

      // Download file from Firebase Storage
      final ref = firebase_storage.FirebaseStorage.instance
          .refFromURL(task.attachmentPath!);
      final bytes = await ref.getData();

      if (bytes == null) {
        throw Exception('Failed to download file from Firebase Storage');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = task.attachmentName ?? 'temp_file';
      final tempFile = File('${tempDir.path}/$fileName');

      // Write bytes to temporary file
      await tempFile.writeAsBytes(bytes);

      // Open the downloaded file
      final result = await OpenFile.open(tempFile.path);

      if (result.type != ResultType.done && context.mounted) {
        _showErrorSnackBar(context, 'Failed to open file: ${result.message}');
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File opened successfully'),
            backgroundColor: AppColors.green,
          ),
        );
      }

      // Clean up temporary file after a delay
      Future.delayed(const Duration(minutes: 5), () async {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      });
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to open cloud file: $e');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }

  void _syncTasks(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<TaskCubit>().syncTasks(user.uid, isManualSync: true);
    }
  }
}
