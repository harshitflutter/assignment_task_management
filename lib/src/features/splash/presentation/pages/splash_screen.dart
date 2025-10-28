import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/auth/presentation/cubit/auth_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _checkAuthStatus(BuildContext context) async {
    // Add 1 second delay before checking auth status
    await Future.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      context.read<AuthCubit>().checkAuthStatus();
    }
  }

  void _navigateToHome(BuildContext context) {
    // Use post-frame callback to avoid navigation conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.tasks);
      }
    });
  }

  void _navigateToSignIn(BuildContext context) {
    // Use post-frame callback to avoid navigation conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.signIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check auth status immediately when splash screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus(context);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _navigateToHome(context);
          } else if (state is AuthUnauthenticated) {
            _navigateToSignIn(context);
          } else if (state is AuthError) {
            _navigateToSignIn(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.task_alt,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),

              // App Name
              Text(
                'Task Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Offline-First Task Management',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 50),

              // Loading Indicator
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
