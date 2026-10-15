import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/tracking/data/models/safe_zone_event_model.dart';

abstract class SafeZoneHistoryRemoteDataSource {
  /// Lay lich su vao/roi vung cua [memberUid] trong khoang [from, to).
  Future<List<SafeZoneEventModel>> getEvents({
    required String memberUid,
    DateTime? from,
    DateTime? to,
    SafeZoneEventType? type,
    int? limit,
  });
}

class SafeZoneHistoryRemoteDataSourceImpl
    implements SafeZoneHistoryRemoteDataSource {
  SafeZoneHistoryRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? AppDependencies.instance.apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<SafeZoneEventModel>> getEvents({
    required String memberUid,
    DateTime? from,
    DateTime? to,
    SafeZoneEventType? type,
    int? limit,
  }) async {
    final query = <String, String>{'member_uid': memberUid.trim()};
    if (from != null) {
      query['from'] = from.toUtc().toIso8601String();
    }
    if (to != null) {
      query['to'] = to.toUtc().toIso8601String();
    }
    if (type != null) {
      query['type'] = type.name;
    }
    if (limit != null) {
      query['limit'] = limit.toString();
    }

    final response = await _apiClient.get(
      ApiEndpoints.safeZoneEvents,
      queryParameters: query,
    );

    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) =>
              SafeZoneEventModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return const <SafeZoneEventModel>[];
  }
}
