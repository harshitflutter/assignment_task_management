import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/features/tasks/data/services/connectivity_sync_service.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';

class AutoSyncWrapper extends StatelessWidget {
  final Widget child;

  const AutoSyncWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        // Initialize auto sync service when TaskCubit is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeAutoSync(context);
        });

        return child;
      },
    );
  }

  void _initializeAutoSync(BuildContext context) {
    // Get the TaskCubit from context
    final taskCubit = context.read<TaskCubit>();

    // Initialize the connectivity sync service
    final connectivitySyncService = ConnectivitySyncService(
      connectivity: Connectivity(),
      taskCubit: taskCubit,
    );

    // Start listening for connectivity changes
    connectivitySyncService.startListening();
  }
}
