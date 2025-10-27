import 'package:task_management/src/features/auth/data/datasources/auth_data_sources.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthDataSources authDataSources;

  AuthRepoImpl(this.authDataSources);

  @override
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    final user = await authDataSources.signIn(email, password);
    return UserEntity(email: user.email ?? '', uid: user.uid);
  }

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    final user = await authDataSources.signUp(
      email: email,
      password: password,
      name: fullName,
      username: username,
    );
    return UserEntity(uid: user.uid, email: user.email ?? '');
  }
}
