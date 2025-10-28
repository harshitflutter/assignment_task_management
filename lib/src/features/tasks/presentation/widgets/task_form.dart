import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/styles/app_text_stryles.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/add_task_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/form_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/attachment_picker.dart';
import 'package:task_management/src/shared/presentation/widgets/custom_test_form_field_widget.dart';

class TaskForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime? selectedDate;
  final String? attachmentPath;
  final String? attachmentName;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final Function(String?, String?) onAttachmentChanged;
  final bool isEditMode;
  final String? taskId; // For edit mode

  const TaskForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedDate,
    required this.attachmentPath,
    required this.attachmentName,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onDateChanged,
    required this.onAttachmentChanged,
    required this.isEditMode,
    this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        _buildTitleField(context),
        SizedBox(height: 24.h),

        // Description Field
        _buildDescriptionField(context),
        SizedBox(height: 24.h),

        // Due Date Field
        _buildDatePicker(context),
        SizedBox(height: 24.h),

        // Attachment Section
        _buildAttachmentSection(context),
        SizedBox(height: 32.h),

        // Validation Messages
        _buildValidationMessages(context),

        SizedBox(height: 24.h),

        _buildSaveButton(context),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Title *',
          style: AppTextStyles.primary400Size16,
        ),
        SizedBox(height: 8.h),
        CustomTestFormFieldWidget(
          textEditingController: titleController,
          hintText: 'What needs to be done?',
          prefixIcon: const Icon(
            Icons.title,
            color: AppColors.primary,
            size: 20,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Task title is required';
            }
            return null;
          },
          onChanged: onTitleChanged,
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.purple,
              width: 2,
            ),
          ),
          enableBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.red,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyles.primary400Size16,
        ),
        SizedBox(height: 8.h),
        CustomTestFormFieldWidget(
          textEditingController: descriptionController,
          hintText: 'Add more details about this task...',
          maxLines: 4,
          prefixIcon: const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          onChanged: onDescriptionChanged,
          fillColor: AppColors.fieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          enableBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: AppColors.red,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.fieldShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.grey.withOpacity(0.2),
              ),
              color: AppColors.white,
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date *',
                        style: AppTextStyles.primary400Size16,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        selectedDate != null
                            ? _formatDate(context, selectedDate!)
                            : 'Select when this task is due',
                        style: AppTextStyles.primary400Size16.copyWith(
                          color: selectedDate != null
                              ? AppColors.purple
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
        ),
        color: AppColors.white,
        boxShadow: const [
          BoxShadow(
            color: AppColors.fieldShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              Text(
                'Attachments',
                style: AppTextStyles.primary400Size16,
              ),
              const Spacer(),
              Text(
                'Optional',
                style: AppTextStyles.hint500Size12.copyWith(
                  color: AppColors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AttachmentPicker(
            attachmentPath: attachmentPath,
            attachmentName: attachmentName,
            onAttachmentChanged: onAttachmentChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationMessages(BuildContext context) {
    return BlocBuilder<AddTaskCubit, AddTaskState>(
      builder: (context, state) {
        if (state is AddTaskInvalid) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.orange,
                  size: 20,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Fields Missing',
                        style: AppTextStyles.primary400Size16.copyWith(
                          color: AppColors.orange,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        state.validationErrors.join(', '),
                        style: AppTextStyles.primary400Size16.copyWith(
                          color: AppColors.orange,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    return context.read<AddTaskCubit>().formatDate(date);
  }

  Future<void> _handleSaveTask(
      BuildContext context, FormInitial formState) async {
    if (formState.title.isNotEmpty && formState.selectedDate != null) {
      if (isEditMode && taskId != null) {
        // Edit mode - update existing task
        final originalTask =
            await context.read<TaskCubit>().getTaskById(taskId!);
        if (originalTask != null && context.mounted) {
          final updatedTask = originalTask.copyWith(
            title: formState.title.trim(),
            description: formState.description.trim(),
            dueDate: formState.selectedDate!,
            attachmentPath: formState.attachmentPath,
            attachmentName: formState.attachmentName,
            updatedAt: DateTime.now(),
          );
          await context.read<TaskCubit>().updateTask(updatedTask);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated successfully'),
                backgroundColor: AppColors.green,
              ),
            );
          }
        }
      } else {
        // Add mode - create new task
        await context.read<AddTaskCubit>().createTaskFromForm(formState);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      }
    }
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocBuilder<AddTaskCubit, AddTaskState>(
      builder: (context, addTaskState) {
        return BlocBuilder<FormCubit, FormCubitState>(
          builder: (context, formState) {
            final currentFormState = formState as FormInitial;
            final addTaskCubit = context.read<AddTaskCubit>();
            final isValid = addTaskCubit.isFormValid(currentFormState);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isValid
                  ? () => _handleSaveTask(context, currentFormState)
                  : null,
              child: AnimatedContainer(
                width: double.infinity,
                height: 56.h,
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.signInGradient1,
                      AppColors.signInGradient2,
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.buttonShadow,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: !isValid ? AppColors.purple : AppColors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          isEditMode ? 'Update' : 'Save',
                          style: AppTextStyles.primary400Size16.copyWith(
                            color:
                                !isValid ? AppColors.purple : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
