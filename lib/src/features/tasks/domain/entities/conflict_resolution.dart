import 'package:equatable/equatable.dart';

class ConflictResolution extends Equatable {
  final String taskId;
  final String title;
  final ConflictType conflictType;
  final DateTime localUpdatedAt;
  final DateTime remoteUpdatedAt;

  const ConflictResolution({
    required this.taskId,
    required this.title,
    required this.conflictType,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
  });

  @override
  List<Object?> get props => [
        taskId,
        title,
        conflictType,
        localUpdatedAt,
        remoteUpdatedAt,
      ];
}

enum ConflictType {
  contentModified,
  statusChanged,
  attachmentChanged,
  deletedLocally,
}

class ConflictResolutionResult extends Equatable {
  final String taskId;
  final ConflictResolutionChoice choice;
  final DateTime resolvedAt;

  const ConflictResolutionResult({
    required this.taskId,
    required this.choice,
    required this.resolvedAt,
  });

  @override
  List<Object?> get props => [taskId, choice, resolvedAt];
}

enum ConflictResolutionChoice {
  keepLocal,
  keepRemote,
  merge,
}
