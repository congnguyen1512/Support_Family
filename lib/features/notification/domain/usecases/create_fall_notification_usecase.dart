import 'package:family_guard/features/notification/domain/repositories/notification_repository.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';

class CreateFallNotificationUseCase {
  CreateFallNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> call({UserLocation? location}) {
    return _repository.createFallNotification(location: location);
  }
}
