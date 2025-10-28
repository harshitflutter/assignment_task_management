import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/src/core/constants/app_strings.dart';

part 'user_profile_state.dart';

// Cubit
class UserProfileCubit extends Cubit<UserProfileState> {
  final FirebaseAuth _auth;

  UserProfileCubit({required FirebaseAuth auth})
      : _auth = auth,
        super(const UserProfileInitial()) {
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = _auth.currentUser;
    if (user != null) {
      emit(UserProfileLoaded(user));
    } else {
      emit(const UserProfileError(AppStrings.noUserFound));
    }
  }

  Future<void> updateProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      emit(UserProfileLoading());

      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }

        // Reload user to get updated data
        await user.reload();
        final updatedUser = _auth.currentUser;

        if (updatedUser != null) {
          emit(UserProfileLoaded(updatedUser));
        } else {
          emit(const UserProfileError(AppStrings.somethingWentWrong));
        }
      } else {
        emit(const UserProfileError(AppStrings.noUserFound));
      }
    } catch (e) {
      emit(const UserProfileError(AppStrings.unexpectedError));
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      emit(const UserProfileInitial()); // Reset to initial state after logout
    } catch (e) {
      emit(const UserProfileError(AppStrings.unexpectedError));
    }
  }
}
