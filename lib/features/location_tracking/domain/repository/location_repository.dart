import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';

abstract class LocationRepository {
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
  });

  Future<UserLocation?> getMyLocation();
  Future<List<UserLocation>> getFamilyLocations();
}
