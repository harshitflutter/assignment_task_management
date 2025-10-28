import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/form_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:uuid/uuid.dart';

part 'add_task_state.dart';

// Cubit
class AddTaskCubit extends Cubit<AddTaskState> {
  final TaskCubit _taskCubit;

  AddTaskCubit({
    required TaskCubit taskCubit,
  })  : _taskCubit = taskCubit,
        super(AddTaskInitial());

  /// Validates the form and emits appropriate state
  void validateForm(FormInitial formState) {
    emit(AddTaskValidating());

    final validationErrors = _validateForm(formState);

    if (validationErrors.isEmpty) {
      emit(AddTaskValid(formState));
    } else {
      emit(AddTaskInvalid(formState, validationErrors));
    }
  }

  /// Emits loading state for update operations
  void setLoading(FormInitial formState) {
    emit(AddTaskCreating(formState));
  }

  /// Emits error state
  void setError(String message) {
    emit(AddTaskError(message));
  }

  /// Creates a task from the form data
  Future<void> createTaskFromForm(FormInitial formState) async {
    emit(AddTaskCreating(formState));

    try {
      // Validate form first
      final validationErrors = _validateForm(formState);
      if (validationErrors.isNotEmpty) {
        emit(AddTaskInvalid(formState, validationErrors));
        return;
      }

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const AddTaskError(AppStrings.noUserFound));
        return;
      }

      // Create task entity
      final task = TaskEntity(
        id: const Uuid().v4(),
        title: formState.title.trim(),
        description: formState.description.trim(),
        dueDate: formState.selectedDate!,
        attachmentPath: formState.attachmentPath,
        attachmentName: formState.attachmentName,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: user.uid,
      );

      // Create task using TaskCubit
      await _taskCubit.createTask(task);

      // Emit success state
      emit(AddTaskCreated(task));
    } catch (e) {
      emit(const AddTaskError(AppStrings.failedToCreateTask));
    }
  }

  /// Resets the add task state
  void resetState() {
    emit(AddTaskInitial());
  }

  /// Validates the form and returns list of validation errors
  List<String> _validateForm(FormInitial formState) {
    final errors = <String>[];

    // Validate title
    if (formState.title.trim().isEmpty) {
      errors.add(AppStrings.titleIsRequired);
    } else if (formState.title.trim().length < 3) {
      errors.add(AppStrings.titleMustBeAtLeast3CharactersLong);
    } else if (formState.title.trim().length > 100) {
      errors.add(AppStrings.titleMustBeLessThan100Characters);
    }

    // Validate description (optional but if provided, should have reasonable length)
    if (formState.description.trim().isNotEmpty &&
        formState.description.trim().length > 500) {
      errors.add(AppStrings.descriptionMustBeLessThan500Characters);
    }

    // Validate due date
    if (formState.selectedDate == null) {
      errors.add(AppStrings.dueDateIsRequired);
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDate = DateTime(
        formState.selectedDate!.year,
        formState.selectedDate!.month,
        formState.selectedDate!.day,
      );

      if (selectedDate.isBefore(today)) {
        errors.add(AppStrings.dueDateCannotBeInThePast);
      }

      // Check if due date is too far in the future (optional validation)
      final maxDate = today.add(const Duration(days: 365));
      if (selectedDate.isAfter(maxDate)) {
        errors.add(AppStrings.dueDateCannotBeMoreThan1YearInTheFuture);
      }
    }

    return errors;
  }

  /// Checks if the form is valid without emitting state
  bool isFormValid(FormInitial formState) {
    return _validateForm(formState).isEmpty;
  }

  /// Gets validation errors for the current form state
  List<String> getValidationErrors(FormInitial formState) {
    return _validateForm(formState);
  }

  /// Formats the date for display
  String formatDate(DateTime date) {
    const months = [
      AppStrings.january,   
      AppStrings.february,
      AppStrings.march,
      AppStrings.april,
      AppStrings.may,
      AppStrings.june,
      AppStrings.july,
      AppStrings.august,
      AppStrings.september,
      AppStrings.october,
      AppStrings.november,
      AppStrings.december
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Gets a user-friendly validation message
  String getValidationMessage(FormInitial formState) {
    final errors = _validateForm(formState);

    if (errors.isEmpty) {
      return '';
    }

    if (errors.length == 1) {
      return errors.first;
    }

    if (errors.length == 2) {
      return '${errors.first} ${AppStrings.and} ${errors.last}';
    }

    return '${errors.take(errors.length - 1).join(', ')}, ${AppStrings.and} ${errors.last}';
  }
}
