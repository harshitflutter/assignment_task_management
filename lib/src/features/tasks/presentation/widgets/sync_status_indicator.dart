import 'package:flutter/material.dart';
import 'package:task_management/src/core/constants/app_strings.dart';

class SyncStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 8),
            _buildStatusText(),
            if (isSyncing) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (isSyncing) {
      return const Icon(
        Icons.sync,
        size: 16,
        color: Colors.white,
      );
    } else if (isOnline) {
      return const Icon(
        Icons.cloud_done,
        size: 16,
        color: Colors.white,
      );
    } else {
      return const Icon(
        Icons.cloud_off,
        size: 16,
        color: Colors.white,
      );
    }
  }

  Widget _buildStatusText() {
    if (isSyncing) {
      return const Text(
        AppStrings.syncing,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (isOnline) {
      if (lastSyncedAt != null) {
        final timeAgo = _getTimeAgo(lastSyncedAt!);
        return Text(
          '${AppStrings.synced} $timeAgo',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
      } else {
        return const Text(
          AppStrings.online,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
      }
    } else {
      return const Text(
        AppStrings.offline,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  Color _getBackgroundColor() {
    if (isSyncing) {
      return Colors.blue;
    } else if (isOnline) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Color _getBorderColor() {
    if (isSyncing) {
      return Colors.blue.shade700;
    } else if (isOnline) {
      return Colors.green.shade700;
    } else {
      return Colors.red.shade700;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${AppStrings.minutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${AppStrings.hoursAgo}';
    } else {
      return '${difference.inDays} ${AppStrings.daysAgo}';
    }
  }
}
