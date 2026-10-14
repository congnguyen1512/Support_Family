import 'package:family_guard/features/login/domain/entities/auth_profile.dart';
import 'package:family_guard/features/login/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthProfile> call() {
    return _repository.getCurrentUser();
  }
}
