import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/location_tracking/domain/repository/location_repository.dart';

class GetMyLocationUseCase {
  GetMyLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<UserLocation?> call() {
    return _repository.getMyLocation();
  }
}
