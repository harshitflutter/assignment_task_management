import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_management/app.dart';
import 'package:task_management/firebase_options.dart';
import 'package:task_management/src/core/services/local_storage_service/hive_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveStorageService().init();
  runApp(const MyApp());
}
