import 'package:equatable/equatable.dart';
import 'package:task_management/src/core/constants/app_strings.dart';

class SyncResult extends Equatable {
  final int uploadedCount;
  final int downloadedCount;
  final int deletedCount;
  final bool isSuccess;
  final String? message;

  const SyncResult({
    required this.uploadedCount,
    required this.downloadedCount,
    required this.deletedCount,
    required this.isSuccess,
    this.message,
  });

  bool get hasChanges =>
      uploadedCount > 0 || downloadedCount > 0 || deletedCount > 0;

  String get summaryMessage {
    if (!isSuccess) {
      return message ?? AppStrings.syncFailed;
    }

    if (!hasChanges) {
      return AppStrings.allTasksAreAlreadySynced;
    }

    final changes = <String>[];
    if (uploadedCount > 0) changes.add('$uploadedCount ${AppStrings.uploaded}');
    if (downloadedCount > 0) {
      changes.add('$downloadedCount ${AppStrings.downloaded}');
    }
    if (deletedCount > 0) changes.add('$deletedCount ${AppStrings.deleted}');

    return '${AppStrings.syncCompleted}: ${changes.join(', ')}';
  }

  @override
  List<Object?> get props => [
        uploadedCount,
        downloadedCount,
        deletedCount,
        isSuccess,
        message,
      ];
}
