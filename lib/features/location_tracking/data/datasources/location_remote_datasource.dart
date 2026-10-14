import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/location_tracking/data/models/user_location_model.dart';

abstract class LocationRemoteDataSource {
  Future<UserLocationModel> updateMyLocation({
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
  Future<UserLocationModel?> getMyLocation();
  Future<List<UserLocationModel>> getFamilyLocations();
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  LocationRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<UserLocationModel>> getFamilyLocations() async {
    final response = await _apiClient.get(ApiEndpoints.locationsFamily);
    final items = response is List ? response : const [];
    return items
        .whereType<Map>()
        .map((item) => UserLocationModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<UserLocationModel?> getMyLocation() async {
    final response = await _apiClient.get(ApiEndpoints.locationsMe);
    if (response == null) {
      return null;
    }
    final map = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return UserLocationModel.fromJson(map);
  }

  @override
  Future<UserLocationModel> updateMyLocation({
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
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.locationsMe,
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'address': address,
        'street': street,
        'ward': ward,
        'district': district,
        'city': city,
        'country': country,
        'place_name': placeName,
        'timestamp': timestamp,
      },
    );
    final map = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return UserLocationModel.fromJson(map);
  }
}
