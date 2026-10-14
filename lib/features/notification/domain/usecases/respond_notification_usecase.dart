import 'package:family_guard/features/notification/domain/entities/app_notification.dart';
import 'package:family_guard/features/notification/domain/repositories/notification_repository.dart';

class RespondNotificationUseCase {
  RespondNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  Future<AppNotification> call({required int id, required String action}) {
    return _repository.respondNotification(id: id, action: action);
  }
}
