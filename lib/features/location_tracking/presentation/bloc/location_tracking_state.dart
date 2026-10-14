import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';

class LocationTrackingState {
  const LocationTrackingState({
    this.isLoading = false,
    this.isPollingFamily = false,
    this.myLocation,
    this.familyLocations = const <UserLocation>[],
    this.errorMessage,
  });

  final bool isLoading;
  final bool isPollingFamily;
  final UserLocation? myLocation;
  final List<UserLocation> familyLocations;
  final String? errorMessage;

  LocationTrackingState copyWith({
    bool? isLoading,
    bool? isPollingFamily,
    UserLocation? myLocation,
    List<UserLocation>? familyLocations,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationTrackingState(
      isLoading: isLoading ?? this.isLoading,
      isPollingFamily: isPollingFamily ?? this.isPollingFamily,
      myLocation: myLocation ?? this.myLocation,
      familyLocations: familyLocations ?? this.familyLocations,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
