import 'package:equatable/equatable.dart';
import 'package:task_management/src/features/tasks/domain/entities/sync_result.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_conflict.dart';

/// Extended sync result that includes conflict information
class ConflictSyncResult extends Equatable {
  final SyncResult syncResult;
  final List<TaskConflict> conflicts;
  final bool hasConflicts;

  ConflictSyncResult({
    required this.syncResult,
    required this.conflicts,
  }) : hasConflicts = conflicts.isNotEmpty;

  @override
  List<Object?> get props => [syncResult, conflicts, hasConflicts];

  /// Create a successful sync result with no conflicts
  factory ConflictSyncResult.success({
    int uploadedCount = 0,
    int downloadedCount = 0,
    int deletedCount = 0,
  }) {
    return ConflictSyncResult(
      syncResult: SyncResult(
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        deletedCount: deletedCount,
        isSuccess: true,
      ),
      conflicts: const [],
    );
  }

  /// Create a sync result with conflicts
  factory ConflictSyncResult.withConflicts({
    required SyncResult syncResult,
    required List<TaskConflict> conflicts,
  }) {
    return ConflictSyncResult(
      syncResult: syncResult,
      conflicts: conflicts,
    );
  }

  /// Create a failed sync result
  factory ConflictSyncResult.failure(String error) {
    return ConflictSyncResult(
      syncResult: const SyncResult(
        uploadedCount: 0,
        downloadedCount: 0,
        deletedCount: 0,
        isSuccess: false,
      ),
      conflicts: const [],
    );
  }
}
