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
      final syncedTask = task.copyWith(isSynced: true);
      await _storageService.saveTask(syncedTask);
    }
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
        // If upload fails, continue with local path (will be uploaded later)
        // TODO: Add proper logging instead of print
        // print('Failed to upload attachment: $e');
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
        // TODO: Add proper logging instead of print
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
