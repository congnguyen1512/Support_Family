import 'package:family_guard/features/profile_security/domain/entities/profile.dart';
import 'package:family_guard/features/profile_security/domain/entities/update_profile_request.dart';
import 'package:family_guard/features/profile_security/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call(UpdateProfileRequest request) {
    return _repository.updateProfile(request);
  }
}
