import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:task_management/src/features/no_internet/data/no_internet_cubit.dart';
import 'package:task_management/src/features/no_internet/presentation/screens/no_internet_screen.dart';

class ConnectivityListenerWrapper extends StatelessWidget {
  final Widget child;
  final void Function(InternetConnectionStatus? status)? onStatusChanged;

  const ConnectivityListenerWrapper({
    super.key,
    required this.child,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetCubit, InternetConnectionStatus?>(
      listener: (context, status) {
        // Ensure we have a valid Navigator context
        if (!context.mounted) return;

        if (status == InternetConnectionStatus.disconnected) {
          // Use post-frame callback to ensure navigation happens after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NoInternetScreen()),
              );
            }
          });
        } else if (status == InternetConnectionStatus.connected) {
          //TODO: Add splash screen
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => SplashScreen()),
          // );
        }
      },
      child: child,
    );
  }
}
