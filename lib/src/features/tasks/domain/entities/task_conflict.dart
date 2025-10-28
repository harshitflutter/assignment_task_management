import 'package:equatable/equatable.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';

/// Represents a conflict between local and cloud versions of a task
class TaskConflict extends Equatable {
  final String taskId;
  final TaskEntity localVersion;
  final TaskEntity cloudVersion;
  final DateTime conflictDetectedAt;
  final ConflictType conflictType;

  const TaskConflict({
    required this.taskId,
    required this.localVersion,
    required this.cloudVersion,
    required this.conflictDetectedAt,
    required this.conflictType,
  });

  @override
  List<Object?> get props => [
        taskId,
        localVersion,
        cloudVersion,
        conflictDetectedAt,
        conflictType,
      ];

  TaskConflict copyWith({
    String? taskId,
    TaskEntity? localVersion,
    TaskEntity? cloudVersion,
    DateTime? conflictDetectedAt,
    ConflictType? conflictType,
  }) {
    return TaskConflict(
      taskId: taskId ?? this.taskId,
      localVersion: localVersion ?? this.localVersion,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      conflictDetectedAt: conflictDetectedAt ?? this.conflictDetectedAt,
      conflictType: conflictType ?? this.conflictType,
    );
  }
}

/// Types of conflicts that can occur
enum ConflictType {
  /// Both versions were modified after last sync
  bothModified,

  /// Local version was deleted but cloud version was modified
  localDeletedCloudModified,

  /// Cloud version was deleted but local version was modified
  cloudDeletedLocalModified,

  /// Both versions were deleted (shouldn't happen but included for completeness)
  bothDeleted,
}

/// Resolution choice for a conflict
enum ConflictResolution {
  /// Keep the local version
  keepLocal,

  /// Keep the cloud version
  keepCloud,

  /// Merge both versions (for future implementation)
  merge,
}

/// Represents the result of resolving a conflict
class ConflictResolutionResult extends Equatable {
  final String taskId;
  final ConflictResolution resolution;
  final TaskEntity? resolvedTask;
  final bool shouldDelete;

  const ConflictResolutionResult({
    required this.taskId,
    required this.resolution,
    this.resolvedTask,
    this.shouldDelete = false,
  });

  @override
  List<Object?> get props => [taskId, resolution, resolvedTask, shouldDelete];
}
