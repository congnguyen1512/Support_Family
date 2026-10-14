sealed class LocationTrackingEvent {
  const LocationTrackingEvent();
}

class LoadMyLocationEvent extends LocationTrackingEvent {
  const LoadMyLocationEvent();
}

class LoadFamilyLocationsEvent extends LocationTrackingEvent {
  const LoadFamilyLocationsEvent({this.showLoader = true});

  final bool showLoader;
}

class StartFamilyLocationPollingEvent extends LocationTrackingEvent {
  const StartFamilyLocationPollingEvent();
}

class StopFamilyLocationPollingEvent extends LocationTrackingEvent {
  const StopFamilyLocationPollingEvent();
}
