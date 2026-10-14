import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/safe_zone/domain/repositories/safe_zone_repository.dart';

class GetSafeZonesUseCase {
  GetSafeZonesUseCase(this._repository);

  final SafeZoneRepository _repository;

  Future<List<SafeZone>> call() {
    return _repository.getSafeZones();
  }
}
