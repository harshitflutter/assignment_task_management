import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/src/features/tasks/data/datasources/task_data_sources.dart';
import 'package:task_management/src/features/tasks/data/models/task_model.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TaskRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  @override
  Future<void> uploadTask(TaskEntity task) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final taskModel = TaskModel.fromEntity(task);
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(task.id)
        .set(taskModel.toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  @override
  Future<List<TaskEntity>> downloadTasks(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    return snapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()).toEntity())
        .toList();
  }
}
