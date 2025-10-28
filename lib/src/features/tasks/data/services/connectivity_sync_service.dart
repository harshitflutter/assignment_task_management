import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';

class ConnectivitySyncService {
  final Connectivity _connectivity;
  final TaskCubit _taskCubit;
  bool _isOnline = false;
  bool _isInitialized = false;

  ConnectivitySyncService({
    required Connectivity connectivity,
    required TaskCubit taskCubit,
  })  : _connectivity = connectivity,
        _taskCubit = taskCubit;

  void startListening() {
    if (_isInitialized) return;

    _isInitialized = true;

    // Check initial connectivity
    _checkInitialConnectivity();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty && results.first != ConnectivityResult.none;

      // If we just came back online, sync tasks
      if (!wasOnline && _isOnline) {
        _syncTasks();
      }
    });
  }

  void _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.isNotEmpty && results.first != ConnectivityResult.none;

    // If we're already online on startup, sync tasks
    if (_isOnline) {
      _syncTasks();
    }
  }

  void _syncTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _taskCubit.syncTasks(user.uid);
    }
  }

  void stopListening() {
    _isInitialized = false;
  }
}
