import 'package:family_guard/features/profile_security/domain/entities/profile.dart';

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.profile,
  });

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final Profile? profile;

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    Profile? profile,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      profile: profile ?? this.profile,
    );
  }
}
