import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/routes/app_router.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/core/services/local_storage_service/hive_storage_service.dart';
import 'package:task_management/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:task_management/src/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:task_management/src/features/no_internet/data/connectivity_listener_wrapper.dart';
import 'package:task_management/src/features/no_internet/data/no_internet_cubit.dart';
import 'package:task_management/src/features/tasks/data/repositories_impl/task_repository_impl.dart';
import 'package:task_management/src/features/tasks/data/services/firebase_storage_service.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/connectivity_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/user_profile_cubit.dart';
import 'package:task_management/src/features/tasks/presentation/widgets/auto_sync_wrapper.dart';
import 'package:uuid/uuid.dart';

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
            BlocProvider<AuthCubit>(
              create: (_) => AuthCubit(auth: FirebaseAuth.instance),
            ),
            BlocProvider<ConnectivityCubit>(
              create: (_) => ConnectivityCubit(connectivity: Connectivity()),
            ),
            BlocProvider<TaskCubit>(
              create: (_) => TaskCubit(
                taskRepository: TaskRepositoryImpl(
                  firestore: FirebaseFirestore.instance,
                  auth: FirebaseAuth.instance,
                  storageService: HiveStorageService.instance,
                  connectivity: Connectivity(),
                  firebaseStorageService: FirebaseStorageServiceImpl(
                    storage: FirebaseStorage.instance,
                    auth: FirebaseAuth.instance,
                  ),
                  uuid: const Uuid(),
                ),
                connectivity: Connectivity(),
              ),
            ),
            BlocProvider<UserProfileCubit>(
              create: (_) => UserProfileCubit(auth: FirebaseAuth.instance),
            ),
          ],
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
              initialRoute: AppRoutes.splash,
              builder: (context, child) => ConnectivityListenerWrapper(
                child: AuthWrapper(
                  child: AutoSyncWrapper(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
