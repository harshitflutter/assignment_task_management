import 'package:flutter/material.dart';
import 'package:task_management/src/features/no_internet/presentation/widgets/no_internet_banner.dart';

class AppWithBanner extends StatelessWidget {
  final Widget child;

  const AppWithBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // No Internet Banner
        const NoInternetBanner(),
        // App Content
        Expanded(child: child),
      ],
    );
  }
}
