import 'dart:typed_data';

import 'package:family_guard/features/profile_security/domain/entities/profile.dart';
import 'package:family_guard/features/profile_security/domain/repositories/profile_repository.dart';

class UploadAvatarUseCase {
  UploadAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) {
    return _repository.uploadAvatar(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}
