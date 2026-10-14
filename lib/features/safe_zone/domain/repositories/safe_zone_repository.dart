import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';

abstract class SafeZoneRepository {
  Future<List<SafeZone>> getSafeZones();
  Future<SafeZone> createSafeZone(SafeZone zone);
  Future<SafeZone> updateSafeZone(SafeZone zone);
  Future<SafeZone> deleteSafeZone(String id);
}
