import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {
  const LoadUserProfile();
}

class UpdateUserProfile extends UserProfileEvent {
  final String displayName;
  final String? photoUrl;

  const UpdateUserProfile({
    required this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, photoUrl];
}

// States
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final User user;

  const UserProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

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
      emit(const UserProfileError('No user found'));
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
          emit(const UserProfileError('Failed to update profile'));
        }
      } else {
        emit(const UserProfileError('No user found'));
      }
    } catch (e) {
      emit(UserProfileError('Failed to update profile: $e'));
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      emit(const UserProfileInitial()); // Reset to initial state after logout
    } catch (e) {
      emit(UserProfileError('Failed to logout: $e'));
    }
  }
}
