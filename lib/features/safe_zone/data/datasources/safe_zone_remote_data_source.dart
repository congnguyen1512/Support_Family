import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/safe_zone/data/models/safe_zone_model.dart';

abstract class SafeZoneRemoteDataSource {
  Future<List<SafeZoneModel>> getSafeZones();
  Future<SafeZoneModel> createSafeZone(SafeZoneModel zone);
  Future<SafeZoneModel> updateSafeZone(SafeZoneModel zone);
  Future<SafeZoneModel> deleteSafeZone(String id);
}

class SafeZoneRemoteDataSourceImpl implements SafeZoneRemoteDataSource {
  SafeZoneRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<SafeZoneModel> createSafeZone(SafeZoneModel zone) async {
    final response = await _apiClient.post(
      ApiEndpoints.safeZones,
      body: zone.toCreateJson(),
    );
    return SafeZoneModel.fromJson(_asJsonMap(response));
  }

  @override
  Future<SafeZoneModel> deleteSafeZone(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.safeZoneById(id));
    return SafeZoneModel.fromJson(_asJsonMap(response));
  }

  @override
  Future<List<SafeZoneModel>> getSafeZones() async {
    final response = await _apiClient.get(ApiEndpoints.safeZones);
    final items = response is List ? response : const [];
    return items
        .whereType<Map>()
        .map((item) => SafeZoneModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<SafeZoneModel> updateSafeZone(SafeZoneModel zone) async {
    final response = await _apiClient.put(
      ApiEndpoints.safeZoneById(zone.id),
      body: zone.toUpdateJson(),
    );
    return SafeZoneModel.fromJson(_asJsonMap(response));
  }

  Map<String, dynamic> _asJsonMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    return Map<String, dynamic>.from(response as Map);
  }
}
