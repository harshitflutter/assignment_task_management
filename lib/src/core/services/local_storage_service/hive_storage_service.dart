import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_management/src/core/services/local_storage_service/hive_adapters.dart';
import 'package:task_management/src/core/services/local_storage_service/hive_storage_keys.dart';
import 'package:task_management/src/features/tasks/data/models/task_model.dart';

class HiveStorageService {
  static HiveStorageService? _instance;

  static HiveStorageService get instance {
    _instance ??= HiveStorageService._();
    return _instance!;
  }

  HiveStorageService._();

  ///initialize the hive box
  Future<void> init({bool isTest = false}) async {
    // Register all adapters
    HiveAdapters.registerAdapters();

    if (isTest) {
      Hive.init('HIVE_TEST');
      await Hive.openBox<dynamic>('task_management');
      await Hive.openBox<TaskModel>(HiveStorageKey.tasksBox);
    } else {
      await Hive.initFlutter();
      await Hive.openBox<dynamic>('task_management');
      await Hive.openBox<TaskModel>(HiveStorageKey.tasksBox);
    }
  }

  /// Returns the box in which the data is stored.
  Box _getBox() => Hive.box<dynamic>('task_management');

  ///To get String Value
  String getStringValue(String key) {
    var box = _getBox();
    var value = box.get(key) as String? ?? '';
    return value;
  }

  ///To get Int Value
  int getIntValue(String key) {
    var box = _getBox();
    var defaultValue = 0;
    var value = box.get(key, defaultValue: defaultValue) as int;
    return value;
  }

  ///to save a value
  void saveValue(dynamic key, dynamic value) {
    _getBox().put(key, value);
  }

  // to get bool value
  bool getBoolValue(String key) {
    var box = _getBox();
    var defaultValue = false;
    var value = box.get(key, defaultValue: defaultValue) as bool;
    return value;
  }

  // to get List value
  List<dynamic> getListValue(String key) {
    var box = _getBox();
    var defaultValue = false;
    var value = box.get(key, defaultValue: defaultValue) as List;
    return value;
  }

  ///to clear data
  void clearData(dynamic key) {
    _getBox().delete(key);
  }

  /// clear all data
  Future<void> clearBox() async {
    await _getBox().clear();
  }

  /// Get tasks box
  Box<TaskModel> _getTasksBox() => Hive.box<TaskModel>(HiveStorageKey.tasksBox);

  /// Save task to local storage
  Future<void> saveTask(TaskModel task) async {
    await _getTasksBox().put(task.id, task);
  }

  /// Get all tasks
  List<TaskModel> getAllTasks() {
    return _getTasksBox().values.toList();
  }

  /// Get task by id
  TaskModel? getTaskById(String id) {
    return _getTasksBox().get(id);
  }

  /// Delete task from local storage
  Future<void> deleteTask(String id) async {
    await _getTasksBox().delete(id);
  }

  /// Get unsynced tasks
  List<TaskModel> getUnsyncedTasks() {
    return _getTasksBox().values.where((task) => !task.isSynced).toList();
  }

  /// Get deleted tasks
  List<TaskModel> getDeletedTasks() {
    return _getTasksBox().values.where((task) => task.isDeleted).toList();
  }

  /// Clear all tasks
  Future<void> clearAllTasks() async {
    await _getTasksBox().clear();
  }
}
