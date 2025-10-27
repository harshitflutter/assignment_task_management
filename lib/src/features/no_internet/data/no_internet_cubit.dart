// Dart imports:
import 'dart:async';
import 'dart:developer';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// MAKE SURE YOUR INTERNET CUBIT IS CORRECT
class InternetCubit extends Cubit<InternetConnectionStatus?> {
  late final StreamSubscription<InternetConnectionStatus> _subscription;
  late final InternetConnectionChecker _checker;

  InternetCubit() : super(null) {
    _checker = InternetConnectionChecker.instance;
    _checker.checkInterval = const Duration(seconds: 2);

    // Listen to status changes
    _subscription = _checker.onStatusChange.listen((status) {
      log('InternetCubit: Status changed to $status');
      emit(status);
    });

    // Check initial status
    _checkInitialStatus();
  }

  void _checkInitialStatus() async {
    try {
      final status = await _checker.connectionStatus;
      log('InternetCubit: Initial status is $status');
      emit(status);
    } catch (e) {
      log('InternetCubit: Error checking initial status: $e');
      emit(InternetConnectionStatus.disconnected);
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
