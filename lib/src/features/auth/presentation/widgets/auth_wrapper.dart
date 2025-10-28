import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/auth/presentation/cubit/auth_cubit.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        final currentRoute = ModalRoute.of(context)?.settings.name;

        if (state is AuthAuthenticated) {
          // Navigate to tasks if coming from splash or sign-in
          if (currentRoute == AppRoutes.splash ||
              currentRoute == AppRoutes.signIn) {
            Navigator.pushReplacementNamed(context, AppRoutes.tasks);
          }
        } else if (state is AuthUnauthenticated) {
          // Navigate to sign-in if coming from splash or tasks
          if (currentRoute == AppRoutes.splash ||
              currentRoute == AppRoutes.tasks) {
            Navigator.pushReplacementNamed(context, AppRoutes.signIn);
          }
        } else if (state is AuthError) {
          // Navigate to sign-in on error if coming from splash
          if (currentRoute == AppRoutes.splash) {
            Navigator.pushReplacementNamed(context, AppRoutes.signIn);
          }
        }
      },
      child: child,
    );
  }
}
