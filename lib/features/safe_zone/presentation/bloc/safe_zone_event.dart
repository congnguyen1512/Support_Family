import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';

sealed class SafeZoneEvent {
  const SafeZoneEvent();
}

class LoadSafeZonesEvent extends SafeZoneEvent {
  const LoadSafeZonesEvent();
}

class CreateSafeZoneEvent extends SafeZoneEvent {
  const CreateSafeZoneEvent(this.zone);

  final SafeZone zone;
}

class UpdateSafeZoneEvent extends SafeZoneEvent {
  const UpdateSafeZoneEvent(this.zone);

  final SafeZone zone;
}

class DeleteSafeZoneEvent extends SafeZoneEvent {
  const DeleteSafeZoneEvent(this.id);

  final String id;
}
