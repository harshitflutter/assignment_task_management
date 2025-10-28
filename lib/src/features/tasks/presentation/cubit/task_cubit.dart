import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/features/tasks/domain/entities/sync_result.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management/src/features/tasks/domain/entities/conflict_sync_result.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_conflict.dart';
import 'package:task_management/src/features/tasks/domain/repositories/task_repository.dart';

part 'task_state.dart';

// Cubit
class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _taskRepository;
  final Connectivity _connectivity;

  TaskCubit({
    required TaskRepository taskRepository,
    required Connectivity connectivity,
  })  : _taskRepository = taskRepository,
        _connectivity = connectivity,
        super(TaskInitial());

  Future<void> loadTasks(String userId) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getAllTasks(userId);

      // Check connectivity status
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.isNotEmpty &&
          connectivityResult.first != ConnectivityResult.none;

      emit(TaskLoaded(tasks, isOnline: isOnline));

      // Only trigger auto-sync if there are tasks to sync
      if (tasks.isNotEmpty && isOnline) {
        // Small delay to ensure UI is updated first
        await Future.delayed(const Duration(milliseconds: 500));
        await syncTasks(userId, isManualSync: false);
      }
    } catch (e) {
      emit(const TaskError(AppStrings.failedToLoadTasks));
    }
  }

  Future<void> createTask(TaskEntity task) async {
    try {
      // Get current state
      final currentState = state;
      if (currentState is TaskLoaded) {
        // Create updated tasks list with new task
        final updatedTasks = List<TaskEntity>.from(currentState.tasks);
        updatedTasks.add(task);

        // Immediately update UI with optimistic update
        emit(currentState.copyWith(tasks: updatedTasks));
      }

      // Create in repository (background operation)
      await _taskRepository.createTask(task);

      // Trigger auto sync if online
      _triggerAutoSyncIfOnline(task.userId);
    } catch (e) {
      // If create fails, revert to previous state
      emit(const TaskError(AppStrings.failedToCreateTask));
      // Reload tasks to get correct state
      await loadTasks(task.userId);
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    try {
      // Get current state
      final currentState = state;
      if (currentState is TaskLoaded) {
        // Find the task to update
        final taskIndex = currentState.tasks.indexWhere((t) => t.id == task.id);
        if (taskIndex != -1) {
          // Create updated tasks list
          final updatedTasks = List<TaskEntity>.from(currentState.tasks);
          updatedTasks[taskIndex] = task;

          // Immediately update UI with optimistic update
          emit(currentState.copyWith(tasks: updatedTasks));
        }
      }

      // Update in repository (background operation)
      await _taskRepository.updateTask(task);

      // Trigger auto sync if online
      _triggerAutoSyncIfOnline(task.userId);
    } catch (e) {
      // If update fails, revert to previous state
      emit(const TaskError(AppStrings.failedToUpdateTask));
      // Reload tasks to get correct state
      await loadTasks(task.userId);
    }
  }

  Future<void> deleteTask(String taskId, String userId) async {
    try {
      // Get current state
      final currentState = state;
      if (currentState is TaskLoaded) {
        // Create updated tasks list without the deleted task
        final updatedTasks =
            currentState.tasks.where((task) => task.id != taskId).toList();

        // Immediately update UI with optimistic update
        emit(currentState.copyWith(tasks: updatedTasks));
      }

      // Delete in repository (background operation)
      await _taskRepository.deleteTask(taskId);

      // Trigger auto sync if online
      _triggerAutoSyncIfOnline(userId);
    } catch (e) {
      // If delete fails, revert to previous state
      emit(const TaskError(AppStrings.failedToDeleteTask));
      // Reload tasks to get correct state
      await loadTasks(userId);
    }
  }

  Future<void> toggleTaskStatus(String taskId, String userId) async {
    try {
      // Get current state
      final currentState = state;
      if (currentState is! TaskLoaded) return;

      // Find the task to update
      final taskIndex =
          currentState.tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) return;

      final task = currentState.tasks[taskIndex];
      final updatedTask = task.copyWith(
        status: task.status == TaskStatus.pending
            ? TaskStatus.completed
            : TaskStatus.pending,
        updatedAt: DateTime.now(),
      );

      // Create updated tasks list
      final updatedTasks = List<TaskEntity>.from(currentState.tasks);
      updatedTasks[taskIndex] = updatedTask;

      // Immediately update UI with optimistic update
      emit(currentState.copyWith(tasks: updatedTasks));

      // Update in repository (background operation)
      await _taskRepository.updateTask(updatedTask);

      // Trigger auto sync if online
      _triggerAutoSyncIfOnline(userId);
    } catch (e) {
      // If update fails, revert to previous state
      emit(const TaskError(AppStrings.failedToToggleTaskStatus));
      // Reload tasks to get correct state
      await loadTasks(userId);
    }
  }

  Future<TaskEntity?> getTaskById(String taskId) async {
    try {
      return await _taskRepository.getTaskById(taskId);
    } catch (e) {
      emit(const TaskError(AppStrings.failedToLoadTask));
      return null;
    }
  }

  Future<void> syncTasks(String userId, {bool isManualSync = false}) async {
    // Use conflict detection for both manual and auto syncs
    await syncTasksWithConflictDetection(userId);
  }

  Future<void> syncTasksWithConflictDetection(String userId) async {
    try {
      // Update sync status to show syncing
      final currentState = state;
      if (currentState is TaskLoaded) {
        emit(currentState.copyWith(isSyncing: true));
      }

      final conflictSyncResult =
          await _taskRepository.syncTasksWithConflictDetection(userId);

      // Get updated tasks after sync
      final tasks = await _taskRepository.getAllTasks(userId);

      // Check connectivity status
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.isNotEmpty &&
          connectivityResult.first != ConnectivityResult.none;

      // Only set lastSyncedAt if there are tasks or if sync had changes
      DateTime? lastSyncedAt;
      if (tasks.isNotEmpty || conflictSyncResult.syncResult.hasChanges) {
        lastSyncedAt = DateTime.now();
      }

      if (conflictSyncResult.hasConflicts) {
        // Emit conflicts detected state
        emit(ConflictsDetected(
            conflictSyncResult.conflicts, conflictSyncResult));
      } else {
        // Emit updated tasks with sync completion
        emit(TaskLoaded(
          tasks,
          isSyncing: false,
          lastSyncedAt: lastSyncedAt,
          isOnline: isOnline,
        ));

        // Emit sync result for UI feedback - only show snackbar for manual syncs or if there are changes
        // if (isManualSync || syncResult.hasChanges || !syncResult.isSuccess) {
        //   emit(TaskSynced(syncResult));
        // }
      }
    } catch (e) {
      // Update sync status to show error
      final currentState = state;
      if (currentState is TaskLoaded) {
        emit(currentState.copyWith(isSyncing: false));
      }
      emit(const TaskError(AppStrings.failedToSyncTasks));
    }
  }

  Future<void> resolveConflict(ConflictResolutionResult resolution) async {
    try {
      await _taskRepository.resolveConflict(resolution);

      // Emit conflict resolved state
      emit(ConflictResolved(resolution.taskId));
    } catch (e) {
      emit(const TaskError(AppStrings.failedToResolveConflict));
    }
  }

  Future<void> completeConflictResolution(String userId) async {
    try {
      // Reload tasks after all conflicts are resolved
      final tasks = await _taskRepository.getAllTasks(userId);

      // Check connectivity status
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.isNotEmpty &&
          connectivityResult.first != ConnectivityResult.none;

      // Emit updated tasks
      emit(TaskLoaded(
        tasks,
        isSyncing: false,
        lastSyncedAt: DateTime.now(),
        isOnline: isOnline,
      ));
      // Emit sync result for UI feedback - only show snackbar for manual syncs or if there are changes
      // if (isManualSync || syncResult.hasChanges || !syncResult.isSuccess) {
      //   emit(TaskSynced(syncResult));
      // }
    } catch (e) {
      emit(const TaskError(AppStrings.failedToCompleteConflictResolution));
    }
  }

  // Helper method to trigger auto sync if online
  Future<void> _triggerAutoSyncIfOnline(String userId) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.isNotEmpty &&
          connectivityResult.first != ConnectivityResult.none;

      if (isOnline) {
        // Add a small delay to prevent rapid successive syncs
        // This helps avoid conflicts when multiple updates happen quickly
        await Future.delayed(const Duration(milliseconds: 500));

        // Trigger sync in background without blocking UI
        syncTasks(userId, isManualSync: false);
      }
    } catch (e) {
      // Ignore connectivity check errors 
    }
  }

  // Method to update connectivity status
  Future<void> updateConnectivityStatus() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.isNotEmpty &&
          connectivityResult.first != ConnectivityResult.none;

      final currentState = state;
      if (currentState is TaskLoaded) {
        emit(currentState.copyWith(isOnline: isOnline));
      }
    } catch (e) {
      // Ignore connectivity check errors
    }
  }
}
