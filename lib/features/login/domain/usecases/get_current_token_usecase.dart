import 'package:family_guard/features/login/domain/repositories/auth_repository.dart';

class GetCurrentTokenUseCase {
  GetCurrentTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<String?> call() {
    return _repository.getCurrentToken();
  }
}
