import 'package:family_guard/features/notification/domain/entities/app_notification.dart';
import 'package:family_guard/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  Future<List<AppNotification>> call() {
    return _repository.getNotifications();
  }
}
