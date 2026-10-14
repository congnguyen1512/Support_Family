import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/safe_zone/domain/repositories/safe_zone_repository.dart';

class DeleteSafeZoneUseCase {
  DeleteSafeZoneUseCase(this._repository);

  final SafeZoneRepository _repository;

  Future<SafeZone> call(String id) {
    return _repository.deleteSafeZone(id);
  }
}
