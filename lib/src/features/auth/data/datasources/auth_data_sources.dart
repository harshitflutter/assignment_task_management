import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/handler/firebase_auth_error_handler.dart';
import 'package:task_management/src/core/mixins/firebase_cloud_collection_key.dart';

class AuthDataSources with FirebaseCloudCollectionKeys {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthDataSources({required this.auth, required this.firestore});

  Future<User> signIn(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: FirebaseAuthErrorHandler.getMessage(e),
      );
    } catch (e) {
      throw Exception("SignIn error: ${e.toString()}");
    }
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    try {
      final usernameQuery = await firestore
          .collection(users)
          .where('username', isEqualTo: username)
          .limit(1) // Limit to 1 for better performance
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message: AppStrings.usernameAlreadyInUse,
        );
      }

      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user!;
      await firestore.collection(users).doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'full_name': name,
        'username': username,
        'createdAt': DateTime.now().toString(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: FirebaseAuthErrorHandler.getMessage(e),
      );
    } catch (e) {
      // Handle Firestore permission errors specifically
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: AppStrings.databaseAccessDenied,
        );
      }
      throw Exception(e.toString());
    }
  }
}
