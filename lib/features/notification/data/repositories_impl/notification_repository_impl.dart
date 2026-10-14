import 'package:family_guard/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:family_guard/features/notification/data/models/respond_notification_request_model.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/notification/domain/entities/app_notification.dart';
import 'package:family_guard/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required NotificationRemoteDataSource remote})
    : _remote = remote;

  final NotificationRemoteDataSource _remote;

  @override
  Future<List<AppNotification>> getNotifications() {
    return _remote.getNotifications();
  }

  @override
  Future<AppNotification> respondNotification({
    required int id,
    required String action,
  }) {
    return _remote.respondNotification(
      id: id,
      request: RespondNotificationRequestModel(action: action),
    );
  }

  @override
  Future<void> createFallNotification({UserLocation? location}) {
    return _remote.createFallNotification(location: location);
  }
}
