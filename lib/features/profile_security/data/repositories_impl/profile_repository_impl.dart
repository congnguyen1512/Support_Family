import 'dart:typed_data';

import 'package:family_guard/features/login/data/datasources/auth_local_data_source.dart';
import 'package:family_guard/features/login/data/models/auth_session_model.dart';
import 'package:family_guard/features/profile_security/data/datasources/profile_remote_data_source.dart';
import 'package:family_guard/features/profile_security/data/models/update_profile_request_model.dart';
import 'package:family_guard/features/profile_security/domain/entities/profile.dart';
import 'package:family_guard/features/profile_security/domain/entities/update_profile_request.dart';
import 'package:family_guard/features/profile_security/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required AuthLocalDataSource authLocalDataSource,
  }) : _remote = remote,
       _authLocalDataSource = authLocalDataSource;

  final ProfileRemoteDataSource _remote;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<Profile> getProfile() async {
    final profile = await _remote.getProfile();
    await _syncSession(profile);
    return profile;
  }

  @override
  Future<Profile> updateProfile(UpdateProfileRequest request) async {
    final profile = await _remote.updateProfile(
      UpdateProfileRequestModel.fromEntity(request),
    );
    await _syncSession(profile);
    return profile;
  }

  @override
  Future<Profile> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    final profile = await _remote.uploadAvatar(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
    await _syncSession(profile);
    return profile;
  }

  Future<void> _syncSession(Profile profile) async {
    final session = await _authLocalDataSource.getSavedSession();
    if (session == null) {
      return;
    }

    final updatedSession = AuthSessionModel.fromEntity(
      session.copyWith(
        user: session.user.copyWith(
          email: profile.email.isEmpty ? session.user.email : profile.email,
        ),
        profile: session.profile.copyWith(
          uid: profile.uid,
          name: profile.name,
          email: profile.email,
          phone: profile.phone,
          birthday: profile.birthday,
          sex: profile.sex,
          address: profile.address,
          role: profile.role,
          avata: profile.avata,
        ),
      ),
    );

    await _authLocalDataSource.saveSession(updatedSession);
  }
}
