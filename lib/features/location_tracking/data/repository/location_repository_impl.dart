import 'package:family_guard/features/location_tracking/data/datasources/location_remote_datasource.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/location_tracking/domain/repository/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({required LocationRemoteDataSource remote})
    : _remote = remote;

  final LocationRemoteDataSource _remote;

  @override
  Future<List<UserLocation>> getFamilyLocations() {
    return _remote.getFamilyLocations();
  }

  @override
  Future<UserLocation?> getMyLocation() {
    return _remote.getMyLocation();
  }

  @override
  Future<UserLocation> updateMyLocation({
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
    return _remote.updateMyLocation(
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
