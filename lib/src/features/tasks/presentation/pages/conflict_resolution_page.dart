import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_conflict.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/conflict_resolution_dialog.dart';

/// Page for resolving task conflicts between local and cloud versions
class ConflictResolutionPage extends StatefulWidget {
  final List<TaskConflict> conflicts;
  final String userId;

  const ConflictResolutionPage({
    super.key,
    required this.conflicts,
    required this.userId,
  });

  @override
  State<ConflictResolutionPage> createState() => _ConflictResolutionPageState();
}

class _ConflictResolutionPageState extends State<ConflictResolutionPage> {
  int _currentConflictIndex = 0;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveNextConflict();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.resolveConflicts,
          style: AppTextStyles.primary600Size18,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isResolving ? null : () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.conflicts.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Text(
                  '${_currentConflictIndex + 1} of ${widget.conflicts.length}',
                  style: AppTextStyles.primary500Size14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: widget.conflicts.isEmpty
          ? _buildNoConflictsView()
          : _buildConflictView(),
    );
  }

  /// Builds the view when no conflicts are found
  Widget _buildNoConflictsView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80.sp,
              color: AppColors.green,
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.noConflictsFound,
              style: AppTextStyles.primary700Size24,
            ),
            SizedBox(height: 12.h),
            Text(
              AppStrings.allYourTasksAreInSync,
              style: AppTextStyles.primary400Size16.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                AppStrings.continueText,
                style: AppTextStyles.primary500Size14.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictView() {
    final currentConflict = widget.conflicts[_currentConflictIndex];

    return Column(
      children: [
        _buildProgressIndicator(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.reviewAndResolveEachConflict,
                  style: AppTextStyles.primary500Size14,
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Text(
                    '${AppStrings.currentConflict}: ${currentConflict.taskId}',
                    style: AppTextStyles.hint500Size12,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: _isResolving ? null : _resolveNextConflict,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                    ),
                    child: Text(
                      AppStrings.resolveThisConflict,
                      style: AppTextStyles.primary500Size14
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the progress indicator showing current conflict resolution progress
  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                AppStrings.resolvingConflicts,
                style: AppTextStyles.primary600Size18,
              ),
              const Spacer(),
              Text(
                '${_currentConflictIndex + 1} ${AppStrings.of} ${widget.conflicts.length}',
                style: AppTextStyles.primary500Size14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: (_currentConflictIndex + 1) / widget.conflicts.length,
            backgroundColor: AppColors.borderColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }

  /// Resolves the next conflict in the list
  Future<void> _resolveNextConflict() async {
    if (_isResolving) return;
    if (_currentConflictIndex >= widget.conflicts.length) return;

    setState(() {
      _isResolving = true;
    });

    try {
      final conflict = widget.conflicts[_currentConflictIndex];
      final resolution = await _showResolutionDialog(conflict);

      if (resolution != null) {
        await _applyResolution(resolution);

        if (!mounted) return;

        if (_currentConflictIndex < widget.conflicts.length - 1) {
          setState(() {
            _currentConflictIndex++;
          });
          await _resolveNextConflict();
        } else {
          final taskCubit = context.read<TaskCubit>();
          await taskCubit.completeConflictResolution(widget.userId);
          _showCompletionDialog();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResolving = false;
        });
      }
    }
  }

  /// Shows the conflict resolution dialog for the given conflict
  Future<ConflictResolution?> _showResolutionDialog(
      TaskConflict conflict) async {
    return await showDialog<ConflictResolution>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConflictResolutionDialog(
        conflict: conflict,
      ),
    );
  }

  /// Applies the selected resolution to the current conflict
  Future<void> _applyResolution(ConflictResolution resolution) async {
    final conflict = widget.conflicts[_currentConflictIndex];

    final resolutionResult = ConflictResolutionResult(
      taskId: conflict.taskId,
      resolution: resolution,
      resolvedTask: resolution == ConflictResolution.keepLocal
          ? conflict.localVersion
          : conflict.cloudVersion,
      shouldDelete: _shouldDeleteTask(conflict, resolution),
    );

    final taskCubit = context.read<TaskCubit>();
    await taskCubit.resolveConflict(resolutionResult);
  }

  /// Determines if a task should be deleted based on conflict type and resolution
  bool _shouldDeleteTask(TaskConflict conflict, ConflictResolution resolution) {
    switch (conflict.conflictType) {
      case ConflictType.localDeletedCloudModified:
        return resolution == ConflictResolution.keepLocal;
      case ConflictType.cloudDeletedLocalModified:
        return resolution == ConflictResolution.keepCloud;
      case ConflictType.bothModified:
        return false;
      case ConflictType.bothDeleted:
        return true;
    }
  }

  /// Shows the completion dialog when all conflicts are resolved
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.green,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              AppStrings.conflictsResolved,
              style: AppTextStyles.primary600Size18,
            ),
          ],
        ),
        content: Text(
          AppStrings.allConflictsHaveBeenSuccessfullyResolved,
          style: AppTextStyles.primary500Size14,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              AppStrings.continueText,
              style: AppTextStyles.primary500Size14.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
