import 'package:flutter/material.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/auth/presentation/pages/sign_in_page.dart';
import 'package:task_management/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:task_management/src/features/splash/presentation/pages/splash_screen.dart';
import 'package:task_management/src/features/tasks/presentation/pages/add_task_page.dart';
import 'package:task_management/src/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:task_management/src/features/tasks/presentation/pages/tasks_page.dart';

class AppRouter {
  static Route<dynamic>? appRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (context) => const SignUpPage());
      case AppRoutes.tasks:
        return MaterialPageRoute(builder: (_) => const TasksPage());
      case AppRoutes.taskDetail:
        final taskId = settings.arguments as String?;
        return MaterialPageRoute(
            builder: (_) => TaskDetailPage(taskId: taskId ?? ''));
      case AppRoutes.addTask:
        final taskId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => AddTaskPage(taskId: taskId));
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
