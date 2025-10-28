import 'package:task_management/src/features/tasks/domain/entities/sync_result.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management/src/features/tasks/domain/entities/conflict_sync_result.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_conflict.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks(String userId);
  Future<TaskEntity?> getTaskById(String id);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<SyncResult> syncTasks(String userId);
  Future<ConflictSyncResult> syncTasksWithConflictDetection(String userId);
  Future<List<TaskEntity>> getUnsyncedTasks();
  Future<void> markTaskAsSynced(String taskId);
  Future<void> resolveConflict(ConflictResolutionResult resolution);
}
