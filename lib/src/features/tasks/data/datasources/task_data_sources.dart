import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskEntity>> getAllTasks(String userId);
  Future<TaskEntity?> getTaskById(String id);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<List<TaskEntity>> getUnsyncedTasks();
  Future<void> markTaskAsSynced(String taskId);
}

abstract class TaskRemoteDataSource {
  Future<void> uploadTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskEntity>> downloadTasks(String userId);
}
