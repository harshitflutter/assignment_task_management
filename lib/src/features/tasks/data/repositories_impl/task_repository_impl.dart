import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/src/core/services/local_storage_service/hive_storage_service.dart';
import 'package:task_management/src/features/tasks/data/models/task_model.dart';
import 'package:task_management/src/features/tasks/data/services/firebase_storage_service.dart';
import 'package:task_management/src/features/tasks/domain/entities/sync_result.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management/src/features/tasks/domain/entities/conflict_sync_result.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_conflict.dart';
import 'package:task_management/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final HiveStorageService _storageService;
  final Connectivity _connectivity;
  final FirebaseStorageService _firebaseStorageService;

  TaskRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required HiveStorageService storageService,
    required Connectivity connectivity,
    required FirebaseStorageService firebaseStorageService,
    required Uuid uuid,
  })  : _firestore = firestore,
        _auth = auth,
        _storageService = storageService,
        _connectivity = connectivity,
        _firebaseStorageService = firebaseStorageService;

  @override
  Future<List<TaskEntity>> getAllTasks(String userId) async {
    // Always get tasks from local storage first (offline-first)
    final localTasks = _storageService
        .getAllTasks()
        .where((task) => task.userId == userId && !task.isDeleted)
        .map((task) => task.toEntity())
        .toList();

    return localTasks;
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

    // Try to sync with Firestore if online
    if (await _isOnline()) {
      try {
        await _uploadTaskToFirestore(taskModel);
        await markTaskAsSynced(task.id);
      } catch (e) {
        // Task remains unsynced, will be synced later
      }
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await _storageService.saveTask(taskModel);

    // Try to sync with Firestore if online
    if (await _isOnline()) {
      try {
        await _uploadTaskToFirestore(taskModel);
        await markTaskAsSynced(task.id);
      } catch (e) {
        // Task remains unsynced, will be synced later
      }
    } else if (task.attachmentRemoved) {
      // If offline and attachment was removed, we need to handle this during sync
      // The attachment will be deleted from Firebase Storage when the task is synced
      log('Task ${task.id} has attachment removed flag set. Will delete from Firebase Storage during sync.');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final task = _storageService.getTaskById(id);
    if (task != null) {
      // Mark as deleted locally
      final deletedTask = task.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveTask(deletedTask);

      // Try to delete from Firestore if online
      if (await _isOnline()) {
        try {
          await _deleteTaskFromFirestore(id);
          await _storageService.deleteTask(id);
        } catch (e) {
          // Task remains in local storage as deleted, will be synced later
        }
      }
    }
  }

  @override
  Future<SyncResult> syncTasks(String userId) async {
    if (!await _isOnline()) {
      throw Exception('No internet connection');
    }

    try {
      int uploadedCount = 0;
      int downloadedCount = 0;
      int deletedCount = 0;

      // Step 1: Upload unsynced tasks to Firestore
      final unsyncedTasks = _storageService
          .getUnsyncedTasks()
          .where((task) => task.userId == userId)
          .toList();

      for (final task in unsyncedTasks) {
        if (task.isDeleted) {
          // Only delete from Firestore if it exists there
          try {
            await _deleteTaskFromFirestore(task.id);
            await _storageService.deleteTask(task.id);
            deletedCount++;
          } catch (e) {
            // If task doesn't exist in Firestore, just remove from local
            await _storageService.deleteTask(task.id);
            deletedCount++;
          }
        } else {
          // Upload task to Firestore
          await _uploadTaskToFirestore(task);
          // Mark as synced without modifying the task content
          final syncedTask = task.copyWith(isSynced: true);
          await _storageService.saveTask(syncedTask);
          uploadedCount++;
        }
      }

      // Step 2: Download new/updated tasks from Firestore
      downloadedCount = await _downloadTasksFromFirestore(userId);

      return SyncResult(
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        deletedCount: deletedCount,
        isSuccess: true,
      );
    } catch (e) {
      throw Exception('Failed to sync tasks: $e');
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
      final syncedTask = task.copyWith(
        isSynced: true,
        attachmentRemoved: false, // Reset attachment removed flag after sync
      );
      await _storageService.saveTask(syncedTask);
    }
  }

  @override
  Future<ConflictSyncResult> syncTasksWithConflictDetection(
      String userId) async {
    if (!await _isOnline()) {
      throw Exception('No internet connection');
    }

    try {
      int uploadedCount = 0;
      int downloadedCount = 0;
      int deletedCount = 0;
      final List<TaskConflict> conflicts = [];

      // Step 1: Upload unsynced tasks to Firestore and detect conflicts
      final unsyncedTasks = _storageService
          .getUnsyncedTasks()
          .where((task) => task.userId == userId)
          .toList();

      log('Found ${unsyncedTasks.length} unsynced tasks for user $userId');
      for (final task in unsyncedTasks) {
        log('Processing unsynced task: ${task.id}, synced: ${task.isSynced}, updated: ${task.updatedAt}');
        if (task.isDeleted) {
          // Check if task exists in Firestore and was modified
          final firestoreTask = await _getTaskFromFirestore(task.id);
          if (firestoreTask != null && !firestoreTask.isDeleted) {
            // Conflict: Local deleted, but cloud modified
            conflicts.add(TaskConflict(
              taskId: task.id,
              localVersion: task.toEntity(),
              cloudVersion: firestoreTask.toEntity(),
              conflictDetectedAt: DateTime.now(),
              conflictType: ConflictType.localDeletedCloudModified,
            ));
            continue; // Don't process this task further
          } else {
            // Safe to delete
            try {
              await _deleteTaskFromFirestore(task.id);
              await _storageService.deleteTask(task.id);
              deletedCount++;
            } catch (e) {
              await _storageService.deleteTask(task.id);
              deletedCount++;
            }
          }
        } else {
          // Check for conflicts before uploading
          final firestoreTask = await _getTaskFromFirestore(task.id);
          if (firestoreTask != null && !firestoreTask.isDeleted) {
            // Both versions exist - check for conflicts
            if (_hasConflict(task, firestoreTask)) {
              log('CONFLICT DETECTED during upload: ${task.id}');
              log('Local: title="${task.title}", desc="${task.description}", status=${task.status}');
              log('Cloud: title="${firestoreTask.title}", desc="${firestoreTask.description}", status=${firestoreTask.status}');
              conflicts.add(TaskConflict(
                taskId: task.id,
                localVersion: task.toEntity(),
                cloudVersion: firestoreTask.toEntity(),
                conflictDetectedAt: DateTime.now(),
                conflictType: ConflictType.bothModified,
              ));
              continue; // Don't process this task further
            } else {
              log('No conflict detected for task ${task.id}, proceeding with upload');
            }
          }

          // No conflict, proceed with upload
          await _uploadTaskToFirestore(task);
          final syncedTask = task.copyWith(isSynced: true);
          await _storageService.saveTask(syncedTask);
          uploadedCount++;
        }
      }

      // Step 2: Download new/updated tasks from Firestore and detect conflicts
      final downloadResult =
          await _downloadTasksFromFirestoreWithConflictDetection(userId);
      downloadedCount = downloadResult.downloadedCount;
      conflicts.addAll(downloadResult.conflicts);

      log('Total conflicts detected: ${conflicts.length}');
      for (final conflict in conflicts) {
        log('Conflict: ${conflict.taskId}, type: ${conflict.conflictType}');
      }

      return ConflictSyncResult.withConflicts(
        syncResult: SyncResult(
          uploadedCount: uploadedCount,
          downloadedCount: downloadedCount,
          deletedCount: deletedCount,
          isSuccess: true,
        ),
        conflicts: conflicts,
      );
    } catch (e) {
      return ConflictSyncResult.failure('Failed to sync tasks: $e');
    }
  }

  @override
  Future<void> resolveConflict(ConflictResolutionResult resolution) async {
    switch (resolution.resolution) {
      case ConflictResolution.keepLocal:
        if (resolution.shouldDelete) {
          // Delete from local storage
          await _storageService.deleteTask(resolution.taskId);
          // Also delete from Firestore if online
          if (await _isOnline()) {
            try {
              await _deleteTaskFromFirestore(resolution.taskId);
            } catch (e) {
              log('Failed to delete task from Firestore: $e');
            }
          }
        } else if (resolution.resolvedTask != null) {
          // Save the resolved task locally
          final taskModel = TaskModel.fromEntity(resolution.resolvedTask!);
          await _storageService.saveTask(taskModel);

          // Upload to Firestore if online
          if (await _isOnline()) {
            try {
              await _uploadTaskToFirestore(taskModel);
              // Mark as synced
              final syncedTask = taskModel.copyWith(isSynced: true);
              await _storageService.saveTask(syncedTask);
            } catch (e) {
              log('Failed to upload resolved task to Firestore: $e');
            }
          }
        }
        break;
      case ConflictResolution.keepCloud:
        if (resolution.shouldDelete) {
          // Delete from local storage
          await _storageService.deleteTask(resolution.taskId);
          // Also delete from Firestore if online
          if (await _isOnline()) {
            try {
              await _deleteTaskFromFirestore(resolution.taskId);
            } catch (e) {
              log('Failed to delete task from Firestore: $e');
            }
          }
        } else if (resolution.resolvedTask != null) {
          // Save the resolved task locally
          final taskModel = TaskModel.fromEntity(resolution.resolvedTask!);
          await _storageService.saveTask(taskModel);

          // Upload to Firestore if online
          if (await _isOnline()) {
            try {
              await _uploadTaskToFirestore(taskModel);
              // Mark as synced
              final syncedTask = taskModel.copyWith(isSynced: true);
              await _storageService.saveTask(syncedTask);
            } catch (e) {
              log('Failed to upload resolved task to Firestore: $e');
            }
          }
        }
        break;
      case ConflictResolution.merge:
        // Future implementation for merging
        throw UnimplementedError('Merge resolution not yet implemented');
    }
  }

  /// Check if there's a conflict between local and cloud versions
  bool _hasConflict(TaskModel local, TaskModel cloud) {
    // Both tasks exist and are not deleted
    if (local.isDeleted || cloud.isDeleted) return false;

    // A conflict exists if:
    // 1. The content is different between local and cloud versions
    // 2. AND either:
    //    - Local task is unsynced (has local changes)
    //    - Cloud version is significantly newer than local version (someone else modified it)

    // Check if content is actually different first
    final hasContentDifference = _isContentDifferent(local, cloud);
    if (!hasContentDifference) {
      log('No conflict: content is identical between local and cloud versions');
      return false;
    }

    // If local task is unsynced, it's a conflict (local changes vs cloud changes)
    if (!local.isSynced) {
      log('Conflict detected: local task is unsynced with different content');
      return true;
    }

    // If local task is synced, check if cloud version is significantly newer
    final timeDifference = cloud.updatedAt.difference(local.updatedAt);

    // If cloud version is significantly newer (more than 5 seconds), it's a conflict
    if (timeDifference.inSeconds > 5) {
      log('Conflict detected: cloud version is significantly newer (${timeDifference.inSeconds}s difference)');
      return true;
    }

    // If cloud version is only slightly newer (within 5 seconds), it's likely the same update
    log('No conflict: cloud version is not significantly newer than local version (${timeDifference.inSeconds}s difference)');
    return false;
  }

  /// Check if the content of two tasks is different (ignoring timestamps and sync status)
  bool _isContentDifferent(TaskModel local, TaskModel cloud) {
    final titleDifferent = local.title != cloud.title;
    final descDifferent = local.description != cloud.description;
    final dueDateDifferent = local.dueDate != cloud.dueDate;

    return titleDifferent || descDifferent || dueDateDifferent;
  }

  /// Get task from Firestore
  Future<TaskModel?> _getTaskFromFirestore(String taskId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .get();

      if (doc.exists) {
        return TaskModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Download tasks from Firestore with conflict detection
  Future<({int downloadedCount, List<TaskConflict> conflicts})>
      _downloadTasksFromFirestoreWithConflictDetection(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    int downloadedCount = 0;
    final List<TaskConflict> conflicts = [];

    for (final doc in snapshot.docs) {
      final firestoreTask = TaskModel.fromJson(doc.data());
      final localTask = _storageService.getTaskById(firestoreTask.id);

      log('Processing Firestore task: ${firestoreTask.id}, local exists: ${localTask != null}, local synced: ${localTask?.isSynced}, local updated: ${localTask?.updatedAt}, cloud updated: ${firestoreTask.updatedAt}');

      if (localTask == null) {
        // New task from Firestore - add it
        await _storageService.saveTask(firestoreTask.copyWith(isSynced: true));
        downloadedCount++;
      } else if (!localTask.isDeleted) {
        // Both versions exist - check for conflicts
        log('Checking task ${firestoreTask.id}: localSynced=${localTask.isSynced}, localUpdated=${localTask.updatedAt}, cloudUpdated=${firestoreTask.updatedAt}');

        if (firestoreTask.isDeleted) {
          // Conflict: Cloud deleted, but local modified
          log('CONFLICT DETECTED during download: Cloud deleted, local modified - ${firestoreTask.id}');
          conflicts.add(TaskConflict(
            taskId: firestoreTask.id,
            localVersion: localTask.toEntity(),
            cloudVersion: firestoreTask.toEntity(),
            conflictDetectedAt: DateTime.now(),
            conflictType: ConflictType.cloudDeletedLocalModified,
          ));
        } else if (_hasConflict(localTask, firestoreTask)) {
          // Both modified - conflict
          log('CONFLICT DETECTED during download: ${firestoreTask.id}');
          log('Local: title="${localTask.title}", desc="${localTask.description}", status=${localTask.status}');
          log('Cloud: title="${firestoreTask.title}", desc="${firestoreTask.description}", status=${firestoreTask.status}');
          conflicts.add(TaskConflict(
            taskId: firestoreTask.id,
            localVersion: localTask.toEntity(),
            cloudVersion: firestoreTask.toEntity(),
            conflictDetectedAt: DateTime.now(),
            conflictType: ConflictType.bothModified,
          ));
        } else if (firestoreTask.updatedAt.isAfter(localTask.updatedAt)) {
          // Firestore version is newer - update local
          log('Updating local task ${firestoreTask.id} with newer cloud version');
          await _storageService
              .saveTask(firestoreTask.copyWith(isSynced: true));
          downloadedCount++;
        } else if (!localTask.isSynced) {
          // Local task is newer but not synced - keep local version
          log('Keeping local version of task ${firestoreTask.id} (local is newer and unsynced)');
          await _storageService.saveTask(localTask.copyWith(isSynced: true));
        } else {
          log('No action needed for task ${firestoreTask.id} (both versions are identical or local is newer)');
        }
      }
    }

    return (downloadedCount: downloadedCount, conflicts: conflicts);
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.isNotEmpty &&
        connectivityResult.first != ConnectivityResult.none;
  }

  Future<void> _uploadTaskToFirestore(TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Create a copy of the task for Firestore upload
    TaskModel taskForUpload = task;

    // Check if this is an update and if attachment was removed
    final existingTask = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(task.id)
        .get();

    if (existingTask.exists) {
      final existingData = existingTask.data();
      if (existingData != null) {
        final existingAttachmentPath =
            existingData['attachmentPath'] as String?;

        // If attachment was removed (current is null but existing had one) OR attachmentRemoved flag is set
        if (((task.attachmentPath == null || task.attachmentPath!.isEmpty) &&
                existingAttachmentPath != null &&
                existingAttachmentPath.isNotEmpty) ||
            task.attachmentRemoved) {
          try {
            // Delete the old attachment from Firebase Storage
            if (existingAttachmentPath != null &&
                existingAttachmentPath.isNotEmpty &&
                existingAttachmentPath
                    .startsWith('https://firebasestorage.googleapis.com')) {
              await _firebaseStorageService.deleteFile(existingAttachmentPath);
              log('Deleted attachment from Firebase Storage: $existingAttachmentPath');
            }
          } catch (e) {
            // If deletion fails, continue with task update
            log('Failed to delete old attachment from Firebase Storage: $e');
          }
        }
      }
    }

    // If task has attachment, upload it to Firebase Storage first
    if (task.attachmentPath != null && task.attachmentPath!.isNotEmpty) {
      try {
        // Check if it's already a Firebase Storage URL
        if (task.attachmentPath!
            .startsWith('https://firebasestorage.googleapis.com')) {
          // Already uploaded to Firebase Storage, use as is
          taskForUpload = task;
        } else {
          // Upload local file to Firebase Storage
          final file = File(task.attachmentPath!);
          if (await file.exists()) {
            final fileName = task.attachmentName ?? 'attachment';
            final downloadUrl =
                await _firebaseStorageService.uploadFile(file, fileName);

            // Update task with Firebase Storage URL
            taskForUpload = task.copyWith(
              attachmentPath: downloadUrl,
              // Keep original filename for display
              attachmentName: task.attachmentName,
            );
          }
        }
      } catch (e) {
        log('Failed to upload attachment: $e');
      }
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(task.id)
        .set(taskForUpload.toJson());
  }

  Future<void> _deleteTaskFromFirestore(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get task to check for attachments
    final task = _storageService.getTaskById(taskId);
    if (task != null && task.attachmentPath != null) {
      try {
        // If attachment is in Firebase Storage, delete it
        if (task.attachmentPath!
            .startsWith('https://firebasestorage.googleapis.com')) {
          await _firebaseStorageService.deleteFile(task.attachmentPath!);
        }
      } catch (e) {
        // If deletion fails, continue with task deletion
        // print('Failed to delete attachment from Firebase Storage: $e');
        log('Failed to delete attachment from Firebase Storage: $e');
      }
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<int> _downloadTasksFromFirestore(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    int downloadedCount = 0;
    for (final doc in snapshot.docs) {
      final firestoreTask = TaskModel.fromJson(doc.data());
      final localTask = _storageService.getTaskById(firestoreTask.id);

      if (localTask == null) {
        // New task from Firestore - add it
        await _storageService.saveTask(firestoreTask.copyWith(isSynced: true));
        downloadedCount++;
      } else if (!localTask.isDeleted) {
        // Only update if local task is not deleted
        if (firestoreTask.updatedAt.isAfter(localTask.updatedAt)) {
          // Firestore version is newer - update local
          await _storageService
              .saveTask(firestoreTask.copyWith(isSynced: true));
          downloadedCount++;
        } else if (!localTask.isSynced) {
          // Local task is newer but not synced - keep local version
          // Just mark as synced
          await _storageService.saveTask(localTask.copyWith(isSynced: true));
        }
      }
      // If local task is deleted, don't overwrite it
    }

    return downloadedCount;
  }
}
