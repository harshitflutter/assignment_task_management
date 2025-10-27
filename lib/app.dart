import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/routes/app_router.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/no_internet/data/connectivity_listener_wrapper.dart';
import 'package:task_management/src/features/no_internet/data/no_internet_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final designSize = (screenWidth < 390 || screenHeight < 844)
            ? const Size(390, 844)
            : Size(screenWidth, screenHeight);

        return MultiBlocProvider(
          providers: [
            BlocProvider<InternetCubit>(create: (_) => InternetCubit()),
          ],
          child: ConnectivityListenerWrapper(
            child: ScreenUtilInit(
              designSize: designSize,
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) => MaterialApp(
                title: 'Task Management',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                  ),
                  fontFamily: "Poppins",
                ),
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRouter.appRoute,
                initialRoute: AppRoutes.signIn,
              ),
            ),
          ),
        );
      },
    );
  }
}
