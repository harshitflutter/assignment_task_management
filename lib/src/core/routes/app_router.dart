import 'package:flutter/material.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/auth/presentation/pages/sign_in_page.dart';
import 'package:task_management/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:task_management/src/features/home/presentation/pages/home_page.dart';

class AppRouter {
  static Route<dynamic>? appRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (context) => const SignUpPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
    return null;
  }
}
