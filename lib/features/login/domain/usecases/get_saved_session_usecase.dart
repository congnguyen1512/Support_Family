import 'package:family_guard/features/login/domain/entities/auth_session.dart';
import 'package:family_guard/features/login/domain/repositories/auth_repository.dart';

class GetSavedSessionUseCase {
  GetSavedSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession?> call() {
    return _repository.getSavedSession();
  }
}
