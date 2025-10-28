import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:task_management/src/features/no_internet/data/no_internet_cubit.dart';
import 'package:task_management/src/features/no_internet/presentation/widgets/app_with_banner.dart';

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
    return BlocBuilder<InternetCubit, InternetConnectionStatus?>(
      builder: (context, status) {
        // Wrap the child with AppWithBanner to show banner when offline
        return AppWithBanner(child: child);
      },
    );
  }
}
