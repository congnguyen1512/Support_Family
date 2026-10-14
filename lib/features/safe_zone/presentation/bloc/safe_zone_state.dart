import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';

class SafeZoneState {
  const SafeZoneState({
    this.isLoading = false,
    this.isSaving = false,
    this.zones = const <SafeZone>[],
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final List<SafeZone> zones;
  final String? errorMessage;
  final String? successMessage;

  SafeZoneState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<SafeZone>? zones,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SafeZoneState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      zones: zones ?? this.zones,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
