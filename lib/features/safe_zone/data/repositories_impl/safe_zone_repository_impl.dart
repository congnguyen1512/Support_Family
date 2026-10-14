import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_remote_data_source.dart';
import 'package:family_guard/features/safe_zone/data/models/safe_zone_model.dart';
import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/safe_zone/domain/repositories/safe_zone_repository.dart';

class SafeZoneRepositoryImpl implements SafeZoneRepository {
  SafeZoneRepositoryImpl({required SafeZoneRemoteDataSource remote})
    : _remote = remote;

  final SafeZoneRemoteDataSource _remote;

  @override
  Future<SafeZone> createSafeZone(SafeZone zone) {
    return _remote.createSafeZone(_toModel(zone));
  }

  @override
  Future<SafeZone> deleteSafeZone(String id) {
    return _remote.deleteSafeZone(id);
  }

  @override
  Future<List<SafeZone>> getSafeZones() {
    return _remote.getSafeZones();
  }

  @override
  Future<SafeZone> updateSafeZone(SafeZone zone) {
    return _remote.updateSafeZone(_toModel(zone));
  }

  SafeZoneModel _toModel(SafeZone zone) {
    if (zone is SafeZoneModel) {
      return zone;
    }

    return SafeZoneModel(
      id: zone.id,
      ownerUid: zone.ownerUid,
      targetUid: zone.targetUid,
      name: zone.name,
      address: zone.address,
      latitude: zone.latitude,
      longitude: zone.longitude,
      radius: zone.radius,
      zoneType: zone.zoneType,
      isActive: zone.isActive,
      timeBasedEnabled: zone.timeBasedEnabled,
      timeSlots: zone.timeSlots,
      alertConfig: zone.alertConfig,
      recipientIds: zone.recipientIds,
      createdAt: zone.createdAt,
      updatedAt: zone.updatedAt,
    );
  }
}
