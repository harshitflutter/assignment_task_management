import 'package:hive/hive.dart';
import 'package:task_management/src/features/tasks/domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  String? attachmentPath;

  @HiveField(5)
  String? attachmentName;

  @HiveField(6)
  TaskStatus status;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  String userId;

  @HiveField(10)
  bool isSynced;

  @HiveField(11)
  bool isDeleted;

  TaskModel({
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

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      attachmentPath: entity.attachmentPath,
      attachmentName: entity.attachmentName,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
      isSynced: entity.isSynced,
      isDeleted: entity.isDeleted,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      attachmentPath: attachmentPath,
      attachmentName: attachmentName,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      isSynced: isSynced,
      isDeleted: isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'attachmentPath': attachmentPath,
      'attachmentName': attachmentName,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      attachmentPath: json['attachmentPath'],
      attachmentName: json['attachmentName'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userId: json['userId'],
      isSynced: json['isSynced'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  TaskModel copyWith({
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
    return TaskModel(
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
}
