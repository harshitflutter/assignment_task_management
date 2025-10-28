// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/utils/snackbar_utils.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/add_task_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/form_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/task_form.dart';

class AddTaskPage extends StatefulWidget {
  final String? taskId;

  const AddTaskPage({super.key, this.taskId});

  bool get isEditMode => taskId != null;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditMode) {
      return FutureBuilder<TaskEntity?>(
        future: context.read<TaskCubit>().getTaskById(widget.taskId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.formBackground,
              body: SafeArea(
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final task = snapshot.data;

          if (task != null) {
            _titleController.text = task.title;
            _descriptionController.text = task.description;
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => FormCubit(
                  initialTitle: task?.title ?? '',
                  initialDescription: task?.description ?? '',
                  initialDate: task?.dueDate,
                  initialAttachmentPath: task?.attachmentPath,
                  initialAttachmentName: task?.attachmentName,
                ),
              ),
              BlocProvider(
                create: (context) => AddTaskCubit(
                  taskCubit: context.read<TaskCubit>(),
                ),
              ),
            ],
            child: _buildScaffold(context),
          );
        },
      );
    } else {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FormCubit(),
          ),
          BlocProvider(
            create: (context) => AddTaskCubit(
              taskCubit: context.read<TaskCubit>(),
            ),
          ),
        ],
        child: _buildScaffold(context),
      );
    }
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.formBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple.withOpacity(0.05),
              AppColors.white.withOpacity(0.05),
              AppColors.formBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              Expanded(
                child: _buildFormContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          _buildBackButton(context),
          SizedBox(width: 16.w),
          _buildTitleSection(),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditMode ? AppStrings.editTask : AppStrings.createNewTask,
            style: AppTextStyles.primary400Size16.copyWith(
              color: AppColors.white,
            ),
          ),
          Text(
            widget.isEditMode
                ? AppStrings.updateYourTaskDetails
                : AppStrings.addDetailsToOrganizeYourWork,
            style: AppTextStyles.hint500Size12.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return BlocListener<TaskCubit, TaskState>(
      listener: (context, state) {
        if (state is TaskCreated) {
          Navigator.pop(context);
          SnackbarUtils.showSuccess(
              context, AppStrings.taskCreatedSuccessfully);
        } else if (state is TaskUpdated) {
          Navigator.pop(context);
          SnackbarUtils.showSuccess(
              context, AppStrings.taskUpdatedSuccessfully);
        } else if (state is TaskError) {
          SnackbarUtils.showError(context, state.message);
        }
      },
      child: BlocListener<FormCubit, FormCubitState>(
        listener: (context, formState) {
          if (formState is FormInitial) {
            _validateForm(context, formState);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<FormCubit, FormCubitState>(
            builder: (context, formState) {
              final currentFormState = formState as FormInitial;
              return TaskForm(
                titleController: _titleController,
                descriptionController: _descriptionController,
                isEditMode: widget.isEditMode,
                taskId: widget.taskId,
                selectedDate: currentFormState.selectedDate,
                attachmentPath: currentFormState.attachmentPath,
                attachmentName: currentFormState.attachmentName,
                onTitleChanged: (title) {
                  context.read<FormCubit>().updateTitle(title);
                },
                onDescriptionChanged: (description) {
                  context.read<FormCubit>().updateDescription(description);
                },
                onDateChanged: (date) {
                  context.read<FormCubit>().updateDate(date);
                },
                onAttachmentChanged: (path, name) {
                  context.read<FormCubit>().updateAttachment(path, name);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Validates current form state using business rules in [AddTaskCubit].
  void _validateForm(BuildContext context, FormInitial formState) {
    context.read<AddTaskCubit>().validateForm(formState);
  }
}
