import 'package:family_guard/features/login/data/datasources/auth_local_data_source.dart';
import 'package:family_guard/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:family_guard/features/login/data/models/auth_session_model.dart';
import 'package:family_guard/features/login/domain/entities/auth_profile.dart';
import 'package:family_guard/features/login/domain/entities/auth_session.dart';
import 'package:family_guard/features/login/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthProfile> getCurrentUser() {
    return _remote.getMe();
  }

  @override
  Future<String?> getCurrentToken() {
    return _local.getAccessToken();
  }

  @override
  Future<AuthSession?> getSavedSession() {
    return _local.getSavedSession();
  }

  @override
  Future<AuthSession?> loadCurrentSession() async {
    final savedSession = await _local.getSavedSession();
    if (savedSession == null) {
      return null;
    }

    final profile = await _remote.getMe();
    final updatedSession = AuthSessionModel.fromEntity(
      savedSession.copyWith(
        user: savedSession.user.copyWith(
          email: profile.email.isEmpty
              ? savedSession.user.email
              : profile.email,
        ),
        profile: savedSession.profile.copyWith(
          uid: profile.uid,
          name: profile.name,
          email: profile.email,
          phone: profile.phone,
          birthday: profile.birthday,
          sex: profile.sex,
          address: profile.address,
          role: profile.role,
          userType: profile.userType,
          avata: profile.avata,
          age: profile.age,
          homeType: profile.homeType ?? savedSession.homeType,
        ),
        age: profile.age ?? savedSession.age,
        homeType: profile.homeType ?? savedSession.homeType,
      ),
    );

    await _local.saveSession(updatedSession);
    return updatedSession;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _remote.login(email: email, password: password);
    await _local.saveSession(session);
    return session;
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Logout should still proceed locally even if the server request fails.
    } finally {
      await _local.clearSession();
    }
  }
}
