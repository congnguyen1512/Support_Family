import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/location_tracking/domain/repository/location_repository.dart';

class UpdateMyLocationUseCase {
  UpdateMyLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<UserLocation> call({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    String? address,
    String? street,
    String? ward,
    String? district,
    String? city,
    String? country,
    String? placeName,
    String? timestamp,
  }) {
    return _repository.updateMyLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      speed: speed,
      address: address,
      street: street,
      ward: ward,
      district: district,
      city: city,
      country: country,
      placeName: placeName,
      timestamp: timestamp,
    );
  }
}
