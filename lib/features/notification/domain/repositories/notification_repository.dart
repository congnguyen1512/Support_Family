import 'package:family_guard/features/notification/domain/entities/app_notification.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<AppNotification> respondNotification({
    required int id,
    required String action,
  });
  Future<void> createFallNotification({UserLocation? location});
}
