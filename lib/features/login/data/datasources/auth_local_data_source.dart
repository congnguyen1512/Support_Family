import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/storage/session_storage.dart';
import 'package:family_guard/features/login/data/models/auth_session_model.dart';
import 'package:family_guard/features/login/domain/entities/auth_session.dart';

abstract class AuthLocalDataSource implements AuthTokenProvider {
  Future<void> saveSession(AuthSession session);
  Future<AuthSessionModel?> getSavedSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final SessionStorage _storage;

  @override
  Future<void> clearSession() {
    return _storage.clear();
  }

  @override
  Future<AuthSessionModel?> getSavedSession() async {
    final json = await _storage.readJson();
    if (json == null || json.isEmpty) {
      return null;
    }

    return AuthSessionModel.fromStoredJson(json);
  }

  @override
  Future<String?> getAccessToken() async {
    final session = await getSavedSession();
    final token = session?.accessToken.trim();
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  @override
  Future<void> saveSession(AuthSession session) {
    final model = AuthSessionModel.fromEntity(session);
    return _storage.writeJson(model.toJson());
  }
}
