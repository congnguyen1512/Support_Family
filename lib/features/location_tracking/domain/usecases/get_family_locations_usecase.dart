import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/location_tracking/domain/repository/location_repository.dart';

class GetFamilyLocationsUseCase {
  GetFamilyLocationsUseCase(this._repository);

  final LocationRepository _repository;

  Future<List<UserLocation>> call() {
    return _repository.getFamilyLocations();
  }
}
