import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/utils/snackbar_utils.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/filter_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/user_profile_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/modern_task_card.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/sync_status_indicator.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/tasks_drawer.dart';
import 'package:task_management/src/features/tasks/presentation/pages/conflict_resolution_page.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  /// Loads tasks for the current authenticated user.
  void _loadTasks(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<TaskCubit>().loadTasks(user.uid);
    }
  }

  /// Manually triggers task synchronization for the current user.
  void _syncTasks(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<TaskCubit>().syncTasks(user.uid, isManualSync: true);
    }
  }

  /// Filters tasks based on the selected filter type.
  List<TaskEntity> _filterTasks(List<TaskEntity> tasks, String filter) {
    switch (filter) {
      case AppStrings.pending:
        return tasks
            .where((task) => task.status == TaskStatus.pending)
            .toList();
      case AppStrings.completed:
        return tasks
            .where((task) => task.status == TaskStatus.completed)
            .toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FilterCubit()),
        BlocProvider(
            create: (context) => UserProfileCubit(auth: FirebaseAuth.instance)),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildModernAppBar(context),
        drawer: const TasksDrawer(),
        body: SafeArea(
          child: _buildTaskListBody(context),
        ),
        floatingActionButton: _buildModernFAB(context),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
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
      iconTheme: const IconThemeData(color: AppColors.white),
      title: Text(
        AppStrings.myTasks,
        style: AppTextStyles.headerTextStyle.copyWith(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // Sync Status Indicator - Only show when there are tasks
        BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TaskLoaded && state.tasks.isNotEmpty) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
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
        // Sync Button
        Container(
          margin: EdgeInsets.only(right: 16.w),
          child: IconButton(
            onPressed: () => _syncTasks(context),
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.sync,
                color: AppColors.white,
                size: 20.sp,
              ),
            ),
            tooltip: AppStrings.syncTasks,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskListBody(BuildContext context) {
    return BlocListener<TaskCubit, TaskState>(
      listener: (context, state) {
        if (state is TaskCreated) {
          SnackbarUtils.showSuccess(
              context, AppStrings.taskCreatedSuccessfully);
        } else if (state is TaskUpdated) {
          SnackbarUtils.showSuccess(
              context, AppStrings.taskUpdatedSuccessfully);
        } else if (state is TaskDeleted) {
          SnackbarUtils.showSuccess(
              context, AppStrings.taskDeletedSuccessfully);
        } else if (state is TaskSynced) {
          _showSyncSnackBar(context, state.syncResult);
        } else if (state is ConflictsDetected) {
          _handleConflictsDetected(context, state);
        }
      },
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadTasks(context);
            });
            return _buildLoadingState();
          } else if (state is TaskLoading) {
            return _buildLoadingState();
          } else if (state is TaskLoaded) {
            return _buildTaskList(context, state.tasks);
          } else if (state is TaskError) {
            return _buildErrorState(context, state.message);
          }
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskEntity> tasks) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filterState) {
        final currentFilterState = filterState as FilterInitial;
        final filteredTasks =
            _filterTasks(tasks, currentFilterState.selectedFilter);

        return Column(
          children: [
            _buildFixedFilterChips(context, currentFilterState),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadTasks(context);
                },
                color: AppColors.drawerGradient1,
                backgroundColor: AppColors.white,
                child: CustomScrollView(
                  slivers: [
                    _buildTaskStats(context, tasks, filteredTasks),
                    if (filteredTasks.isEmpty)
                      _buildEmptyStateSliver()
                    else
                      _buildTaskListSliver(context, filteredTasks),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFixedFilterChips(
      BuildContext context, FilterInitial filterState) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.fieldShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: filterState.availableFilters.map((filter) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildModernFilterChip(
                context,
                filter,
                filterState.selectedFilter == filter,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernFilterChip(
    BuildContext context,
    String filter,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => context.read<FilterCubit>().changeFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppColors.drawerGradient1,
                    AppColors.drawerGradient2
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.grey.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.drawerGradient1.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            filter,
            style: AppTextStyles.primary500Size14.copyWith(
              color: isSelected ? AppColors.white : AppColors.black,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskStats(
    BuildContext context,
    List<TaskEntity> allTasks,
    List<TaskEntity> filteredTasks,
  ) {
    final completedTasks =
        allTasks.where((task) => task.status == TaskStatus.completed).length;
    final pendingTasks =
        allTasks.where((task) => task.status == TaskStatus.pending).length;
    final overdueTasks = allTasks
        .where((task) =>
            task.dueDate.isBefore(DateTime.now()) &&
            task.status == TaskStatus.pending)
        .length;

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              AppColors.white.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: AppColors.fieldShadow,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem(
                'Total', allTasks.length.toString(), AppColors.drawerGradient1),
            _buildStatDivider(),
            _buildStatItem(
                'Completed', completedTasks.toString(), AppColors.green),
            _buildStatDivider(),
            _buildStatItem(
                'Pending', pendingTasks.toString(), AppColors.orange),
            _buildStatDivider(),
            _buildStatItem('Overdue', overdueTasks.toString(), AppColors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.primary700Size24.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTextStyles.hint500Size12.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: AppColors.grey.withOpacity(0.3),
    );
  }

  Widget _buildTaskListSliver(BuildContext context, List<TaskEntity> tasks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final task = tasks[index];
          return ModernTaskCard(
            task: task,
            onToggleStatus: () {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                context.read<TaskCubit>().toggleTaskStatus(task.id, userId);
              }
            },
            onDelete: () => _showDeleteConfirmationDialog(context, task),
            onEdit: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addTask,
                arguments: task.id,
              );
            },
          );
        },
        childCount: tasks.length,
      ),
    );
  }

  Widget _buildEmptyStateSliver() {
    return SliverFillRemaining(
      child: _buildEmptyState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.drawerGradient1.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppColors.drawerGradient1,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading your tasks...',
            style: AppTextStyles.primary500Size14.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: AppTextStyles.primary600Size18,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: AppTextStyles.hint400Size14.copyWith(
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => _loadTasks(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.drawerGradient1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Try Again',
              style: AppTextStyles.buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: AppColors.drawerGradient1.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt,
              size: 64.sp,
              color: AppColors.drawerGradient1,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppStrings.noTasksYet,
            style: AppTextStyles.primary600Size18,
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.createYourFirstTask,
            style: AppTextStyles.hint400Size14.copyWith(
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.drawerGradient1, AppColors.drawerGradient2],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.drawerGradient1.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addTask);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Icons.add,
          color: AppColors.white,
          size: 28.sp,
        ),
      ),
    );
  }

  /// Shows sync result snackbar with appropriate styling.
  void _showSyncSnackBar(BuildContext context, dynamic syncResult) {
    if (syncResult.isSuccess) {
      SnackbarUtils.showSuccess(context, syncResult.summaryMessage);
    } else {
      SnackbarUtils.showError(context, syncResult.summaryMessage);
    }
  }

  /// Shows confirmation dialog before deleting a task.
  void _showDeleteConfirmationDialog(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
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
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.buttonTextStyleSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                context.read<TaskCubit>().deleteTask(task.id, userId);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              AppStrings.delete,
              style: AppTextStyles.buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to conflict resolution page when conflicts are detected.
  void _handleConflictsDetected(BuildContext context, ConflictsDetected state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ConflictResolutionPage(
            conflicts: state.conflicts,
            userId: user.uid,
          ),
        ),
      );
    }
  }
}
