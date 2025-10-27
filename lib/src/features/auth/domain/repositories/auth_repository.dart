import '../entities/user_entity.dart';

abstract class AuthRepo {
  Future<UserEntity?> signIn({required String email, required String password});

  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  });
}
