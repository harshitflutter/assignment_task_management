import 'package:flutter/material.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/features/tasks/domain/entities/conflict_resolution.dart';

class ConflictResolutionDialog extends StatelessWidget {
  final ConflictResolution conflict;
  final Function(ConflictResolutionChoice) onResolve;

  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conflict Detected'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.thisTaskHasBeenModifiedBothLocallyAndOnTheServer}: "${conflict.title}"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.thisTaskHasBeenModifiedBothLocallyAndOnTheServer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.conflictType}: ${_getConflictTypeText(conflict.conflictType)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.howWouldYouLikeToResolveThisConflict,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onResolve(ConflictResolutionChoice.keepLocal);
          },
          child: const Text('Keep Local'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onResolve(ConflictResolutionChoice.keepRemote);
          },
          child: const Text('Keep Cloud'),
        ),
        if (conflict.conflictType == ConflictType.contentModified)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onResolve(ConflictResolutionChoice.merge);
            },
            child: const Text('Merge'),
          ),
      ],
    );
  }

  String _getConflictTypeText(ConflictType type) {
    switch (type) {
      case ConflictType.contentModified:
        return 'Content Modified';
      case ConflictType.statusChanged:
        return 'Status Changed';
      case ConflictType.attachmentChanged:
        return 'Attachment Changed';
      case ConflictType.deletedLocally:
        return 'Deleted Locally';
    }
  }
}
