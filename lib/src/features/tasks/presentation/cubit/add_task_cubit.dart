import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/form_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:uuid/uuid.dart';

// Events
abstract class AddTaskEvent extends Equatable {
  const AddTaskEvent();

  @override
  List<Object?> get props => [];
}

class ValidateForm extends AddTaskEvent {
  final FormInitial formState;
  const ValidateForm(this.formState);

  @override
  List<Object?> get props => [formState];
}

class CreateTaskFromForm extends AddTaskEvent {
  final FormInitial formState;
  const CreateTaskFromForm(this.formState);

  @override
  List<Object?> get props => [formState];
}

class ResetAddTaskState extends AddTaskEvent {
  const ResetAddTaskState();
}

// States
abstract class AddTaskState extends Equatable {
  const AddTaskState();

  @override
  List<Object?> get props => [];
}

class AddTaskInitial extends AddTaskState {}

class AddTaskValidating extends AddTaskState {}

class AddTaskValid extends AddTaskState {
  final FormInitial formState;
  const AddTaskValid(this.formState);

  @override
  List<Object?> get props => [formState];
}

class AddTaskInvalid extends AddTaskState {
  final FormInitial formState;
  final List<String> validationErrors;
  const AddTaskInvalid(this.formState, this.validationErrors);

  @override
  List<Object?> get props => [formState, validationErrors];
}

class AddTaskCreating extends AddTaskState {
  final FormInitial formState;
  const AddTaskCreating(this.formState);

  @override
  List<Object?> get props => [formState];
}

class AddTaskCreated extends AddTaskState {
  final TaskEntity task;
  const AddTaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

class AddTaskError extends AddTaskState {
  final String message;
  const AddTaskError(this.message);

  @override
  List<Object?> get props => [message];
}

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
        emit(const AddTaskError('User not authenticated'));
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
      emit(AddTaskError('Failed to create task: $e'));
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
      errors.add('Title is required');
    } else if (formState.title.trim().length < 3) {
      errors.add('Title must be at least 3 characters long');
    } else if (formState.title.trim().length > 100) {
      errors.add('Title must be less than 100 characters');
    }

    // Validate description (optional but if provided, should have reasonable length)
    if (formState.description.trim().isNotEmpty &&
        formState.description.trim().length > 500) {
      errors.add('Description must be less than 500 characters');
    }

    // Validate due date
    if (formState.selectedDate == null) {
      errors.add('Due date is required');
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDate = DateTime(
        formState.selectedDate!.year,
        formState.selectedDate!.month,
        formState.selectedDate!.day,
      );

      if (selectedDate.isBefore(today)) {
        errors.add('Due date cannot be in the past');
      }

      // Check if due date is too far in the future (optional validation)
      final maxDate = today.add(const Duration(days: 365));
      if (selectedDate.isAfter(maxDate)) {
        errors.add('Due date cannot be more than 1 year in the future');
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
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
      return '${errors.first} and ${errors.last}';
    }

    return '${errors.take(errors.length - 1).join(', ')}, and ${errors.last}';
  }
}
