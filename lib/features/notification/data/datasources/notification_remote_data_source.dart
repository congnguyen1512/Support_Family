import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/notification/data/models/notification_model.dart';
import 'package:family_guard/features/notification/data/models/respond_notification_request_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> respondNotification({
    required int id,
    required RespondNotificationRequestModel request,
  });
  Future<void> createFallNotification({UserLocation? location});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get(ApiEndpoints.notifications);
    final items = response is List ? response : const [];
    return items
        .whereType<Map>()
        .map(
          (item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<NotificationModel> respondNotification({
    required int id,
    required RespondNotificationRequestModel request,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.notificationRespond(id),
      body: request.toJson(),
    );
    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return NotificationModel.fromJson(json);
  }

  @override
  Future<void> createFallNotification({UserLocation? location}) async {
    await _apiClient.post(
      ApiEndpoints.notificationsFall,
      body: location == null
          ? null
          : {
              'location': {
                'latitude': location.latitude,
                'longitude': location.longitude,
              },
            },
    );
  }
}
