import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/safe_zone/domain/repositories/safe_zone_repository.dart';

class UpdateSafeZoneUseCase {
  UpdateSafeZoneUseCase(this._repository);

  final SafeZoneRepository _repository;

  Future<SafeZone> call(SafeZone zone) {
    return _repository.updateSafeZone(zone);
  }
}
