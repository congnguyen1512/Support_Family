import 'package:family_guard/core/network/network_error_mapper.dart';
import 'package:family_guard/features/profile_security/domain/entities/profile.dart';
import 'package:family_guard/features/profile_security/domain/entities/update_profile_request.dart';
import 'package:family_guard/features/profile_security/domain/usecases/get_profile_usecase.dart';
import 'package:family_guard/features/profile_security/domain/usecases/upload_avatar_usecase.dart';
import 'package:family_guard/features/profile_security/domain/usecases/update_profile_usecase.dart';
import 'package:family_guard/features/profile_security/presentation/cubit/profile_state.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, Uint8List;

class ProfileCubit extends ChangeNotifier {
  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UploadAvatarUseCase uploadAvatarUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _uploadAvatarUseCase = uploadAvatarUseCase;

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;

  ProfileState _state = const ProfileState();
  ProfileState get state => _state;

  Future<Profile?> loadProfile() async {
    _state = _state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    notifyListeners();

    try {
      final profile = await _getProfileUseCase();
      _state = _state.copyWith(
        isLoading: false,
        clearError: true,
        profile: profile,
      );
      notifyListeners();
      return profile;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      notifyListeners();
      return null;
    }
  }

  Future<Profile?> updateProfile(UpdateProfileRequest request) async {
    if (!request.hasChanges) {
      return _state.profile;
    }

    _state = _state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );
    notifyListeners();

    try {
      final profile = await _updateProfileUseCase(request);
      _state = _state.copyWith(
        isSaving: false,
        clearError: true,
        profile: profile,
        successMessage: 'Cap nhat thong tin thanh cong.',
      );
      notifyListeners();
      return profile;
    } catch (error) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      notifyListeners();
      return null;
    }
  }

  Future<Profile?> updateName(String value) {
    return updateProfile(UpdateProfileRequest(name: value));
  }

  Future<Profile?> updateEmail(String value) {
    return updateProfile(UpdateProfileRequest(email: value));
  }

  Future<Profile?> updatePhone(String value) {
    return updateProfile(UpdateProfileRequest(phone: value));
  }

  Future<Profile?> updateRole(String value) {
    return updateProfile(UpdateProfileRequest(role: value));
  }

  Future<Profile?> updateBirthday(String value) {
    return updateProfile(UpdateProfileRequest(birthday: value));
  }

  Future<Profile?> updateSex(String value) {
    return updateProfile(UpdateProfileRequest(sex: value));
  }

  Future<Profile?> updateAddress(String value) {
    return updateProfile(UpdateProfileRequest(address: value));
  }

  Future<Profile?> updateAvatar(String value) {
    return updateProfile(UpdateProfileRequest(avata: value));
  }

  Future<Profile?> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    _state = _state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );
    notifyListeners();

    try {
      final profile = await _uploadAvatarUseCase(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      _state = _state.copyWith(
        isSaving: false,
        clearError: true,
        profile: profile,
        successMessage: 'Cap nhat anh dai dien thanh cong.',
      );
      notifyListeners();
      return profile;
    } catch (error) {
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      notifyListeners();
      return null;
    }
  }
}
