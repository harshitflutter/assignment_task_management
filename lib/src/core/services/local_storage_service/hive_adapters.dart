import 'package:hive/hive.dart';
import 'package:task_management/src/features/tasks/data/models/task_model.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';

class HiveAdapters {
  static void registerAdapters() {
    // Register TaskStatus adapter
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }

    // Register TaskModel adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
  }
}
