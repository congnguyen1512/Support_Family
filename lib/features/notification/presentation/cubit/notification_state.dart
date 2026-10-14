import 'package:family_guard/features/notification/domain/entities/app_notification.dart';

class NotificationState {
  const NotificationState({
    this.isLoading = false,
    this.isResponding = false,
    this.errorMessage,
    this.successMessage,
    this.notifications = const <AppNotification>[],
  });

  final bool isLoading;
  final bool isResponding;
  final String? errorMessage;
  final String? successMessage;
  final List<AppNotification> notifications;

  NotificationState copyWith({
    bool? isLoading,
    bool? isResponding,
    String? errorMessage,
    String? successMessage,
    List<AppNotification>? notifications,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      isResponding: isResponding ?? this.isResponding,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      notifications: notifications ?? this.notifications,
    );
  }
}
