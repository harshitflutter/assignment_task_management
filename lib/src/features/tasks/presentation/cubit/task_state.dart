part of "task_cubit.dart";
// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final bool isOnline;

  const TaskLoaded(
    this.tasks, {
    this.isSyncing = false,
    this.lastSyncedAt,
    this.isOnline = true,
  });

  @override
  List<Object?> get props => [tasks, isSyncing, lastSyncedAt, isOnline];

  TaskLoaded copyWith({
    List<TaskEntity>? tasks,
    bool? isSyncing,
    DateTime? lastSyncedAt,
    bool? isOnline,
  }) {
    return TaskLoaded(
      tasks ?? this.tasks,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskCreated extends TaskState {
  final TaskEntity task;
  const TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskUpdated extends TaskState {
  final TaskEntity task;
  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskDeleted extends TaskState {
  final String taskId;
  const TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskSynced extends TaskState {
  final SyncResult syncResult;
  const TaskSynced(this.syncResult);

  @override
  List<Object?> get props => [syncResult];
}

class ConflictsDetected extends TaskState {
  final List<TaskConflict> conflicts;
  final ConflictSyncResult syncResult;
  const ConflictsDetected(this.conflicts, this.syncResult);

  @override
  List<Object?> get props => [conflicts, syncResult];
}

class ConflictResolved extends TaskState {
  final String taskId;
  const ConflictResolved(this.taskId);

  @override
  List<Object?> get props => [taskId];
}