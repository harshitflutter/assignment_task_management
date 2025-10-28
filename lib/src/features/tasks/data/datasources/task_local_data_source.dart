import 'package:task_management/src/core/services/local_storage_service/hive_storage_service.dart';
import 'package:task_management/src/features/tasks/data/datasources/task_data_sources.dart';
import 'package:task_management/src/features/tasks/data/models/task_model.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final HiveStorageService _storageService;

  TaskLocalDataSourceImpl({required HiveStorageService storageService})
      : _storageService = storageService;

  @override
  Future<List<TaskEntity>> getAllTasks(String userId) async {
    final tasks = _storageService
        .getAllTasks()
        .where((task) => task.userId == userId && !task.isDeleted)
        .map((task) => task.toEntity())
        .toList();
    return tasks;
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final task = _storageService.getTaskById(id);
    return task?.toEntity();
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await _storageService.saveTask(taskModel);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await _storageService.saveTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    final task = _storageService.getTaskById(id);
    if (task != null) {
      final deletedTask = task.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveTask(deletedTask);
    }
  }

  @override
  Future<List<TaskEntity>> getUnsyncedTasks() async {
    return _storageService
        .getUnsyncedTasks()
        .map((task) => task.toEntity())
        .toList();
  }

  @override
  Future<void> markTaskAsSynced(String taskId) async {
    final task = _storageService.getTaskById(taskId);
    if (task != null) {
      final syncedTask = task.copyWith(isSynced: true);
      await _storageService.saveTask(syncedTask);
    }
  }
}
