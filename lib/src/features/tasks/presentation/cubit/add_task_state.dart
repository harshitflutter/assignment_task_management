// States
part of "add_task_cubit.dart";

abstract class AddTaskState extends Equatable {
  const AddTaskState();

  @override
  List<Object?> get props => [];
}

class AddTaskInitial extends AddTaskState {}

class AddTaskValidating extends AddTaskState {}

class AddTaskLoading extends AddTaskState {}

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