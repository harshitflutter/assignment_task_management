import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_state.dart';

// Cubit
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;

  ConnectivityCubit({required Connectivity connectivity})
      : _connectivity = connectivity,
        super(ConnectivityInitial()) {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _handleConnectivityChange(results);
    });

    // Check initial connectivity
    checkConnectivity();
  }

  void checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOnline =
        results.isNotEmpty && results.first != ConnectivityResult.none;

    if (isOnline) {
      emit(ConnectivityOnline(lastConnectedAt: DateTime.now()));
    } else {
      emit(ConnectivityOffline(lastDisconnectedAt: DateTime.now()));
    }
  }

  bool get isOnline {
    return state is ConnectivityOnline;
  }

  bool get isOffline {
    return state is ConnectivityOffline;
  }

  DateTime? get lastConnectedAt {
    if (state is ConnectivityOnline) {
      return (state as ConnectivityOnline).lastConnectedAt;
    }
    return null;
  }

  DateTime? get lastDisconnectedAt {
    if (state is ConnectivityOffline) {
      return (state as ConnectivityOffline).lastDisconnectedAt;
    }
    return null;
  }
}
