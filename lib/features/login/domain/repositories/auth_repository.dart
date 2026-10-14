import 'package:family_guard/features/login/domain/entities/auth_profile.dart';
import 'package:family_guard/features/login/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<void> logout();
  Future<AuthProfile> getCurrentUser();
  Future<AuthSession?> getSavedSession();
  Future<AuthSession?> loadCurrentSession();
  Future<String?> getCurrentToken();
}
