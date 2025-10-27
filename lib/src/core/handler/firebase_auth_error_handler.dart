import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/src/core/constants/app_strings.dart';

class FirebaseAuthErrorHandler {
  /// Returns a user-friendly message based on FirebaseAuthException code
  static String getMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppStrings.noUserFound;
      case 'wrong-password':
        return AppStrings.incorrectPassword;
      case 'invalid-email':
        return AppStrings.emailFormatInvalid;
      case 'user-disabled':
        return AppStrings.userDisabled;
      case 'email-already-in-use':
        return AppStrings.emailAlreadyInUse;
      case 'weak-password':
        return AppStrings.passwordTooWeak;
      case 'operation-not-allowed':
        return AppStrings.operationNotAllowed;
      case 'too-many-requests':
        return AppStrings.tooManyRequests;
      default:
        return e.message ?? AppStrings.unexpectedError;
    }
  }
}
