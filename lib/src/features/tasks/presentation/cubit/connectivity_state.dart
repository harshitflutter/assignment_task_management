part of "connectivity_cubit.dart";

// States
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {
  final DateTime lastConnectedAt;

  const ConnectivityOnline({required this.lastConnectedAt});

  @override
  List<Object?> get props => [lastConnectedAt];
}

class ConnectivityOffline extends ConnectivityState {
  final DateTime lastDisconnectedAt;

  const ConnectivityOffline({required this.lastDisconnectedAt});

  @override
  List<Object?> get props => [lastDisconnectedAt];
}
