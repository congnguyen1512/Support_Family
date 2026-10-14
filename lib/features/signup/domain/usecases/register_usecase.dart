import 'package:family_guard/features/login/domain/entities/auth_session.dart';
import 'package:family_guard/features/login/domain/repositories/auth_repository.dart';
import 'package:family_guard/features/signup/data/models/register_request_model.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call(RegisterRequestModel request) {
    return _repository.register(request);
  }
}
