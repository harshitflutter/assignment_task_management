import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'task_entity.g.dart';

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed
}

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String? attachmentPath;
  final String? attachmentName;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final bool isSynced;
  final bool isDeleted;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.attachmentPath,
    this.attachmentName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isSynced = false,
    this.isDeleted = false,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? attachmentPath,
    String? attachmentName,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentName: attachmentName ?? this.attachmentName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        attachmentPath,
        attachmentName,
        status,
        createdAt,
        updatedAt,
        userId,
        isSynced,
        isDeleted,
      ];
}
