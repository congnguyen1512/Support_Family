import 'dart:async';

import 'package:family_guard/core/push_notification/push_notification_service.dart';
import 'package:family_guard/core/realtime/supabase_realtime_client.dart';
import 'package:family_guard/features/notification/domain/entities/app_notification.dart';
import 'package:family_guard/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter/foundation.dart';

class NotificationBadgeController extends ChangeNotifier {
  NotificationBadgeController({
    required GetNotificationsUseCase getNotificationsUseCase,
    required SupabaseRealtimeClient realtimeClient,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _realtimeClient = realtimeClient;

  final GetNotificationsUseCase _getNotificationsUseCase;
  final SupabaseRealtimeClient _realtimeClient;

  RealtimeWatchSubscription? _realtimeSubscription;
  Timer? _realtimeRefreshDebounce;
  Timer? _pollingTimer;
  bool _started = false;
  bool _isRefreshing = false;
  bool _hasPendingNotifications = false;

  /// Id notification lon nhat da xu ly; null = chua co moc (lan tai dau tien
  /// chi lay moc, khong bao lai thong bao cu).
  int? _lastSeenNotificationId;
  static const _alertMaxAge = Duration(minutes: 15);

  bool get hasPendingNotifications => _hasPendingNotifications;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    await refresh();

    _pollingTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      refresh();
    });

    _realtimeSubscription ??= await _realtimeClient.watchNotifications(
      _scheduleRefresh,
    );
  }

  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    try {
      final notifications = await _getNotificationsUseCase();
      final hasPending = notifications.any(
        (notification) =>
            notification.processing == 'dagui' &&
                ((notification.senderName ?? '').trim().isNotEmpty ||
                    (notification.senderRelation ?? '').trim().isNotEmpty) ||
            _isFallAlertNotification(notification),
      );
      if (hasPending != _hasPendingNotifications) {
        _hasPendingNotifications = hasPending;
        notifyListeners();
      }
      _alertNewSafeZoneExits(notifications);
    } catch (_) {
      // Keep the current badge state when a refresh fails.
    } finally {
      _isRefreshing = false;
    }
  }

  bool _isFallAlertNotification(dynamic notification) {
    final title = (notification.title ?? '').toString().toLowerCase();
    final content = (notification.content ?? '').toString().toLowerCase();
    return title.contains('té ngã') || content.contains('té ngã');
  }

  bool _isSafeZoneExitNotification(AppNotification notification) {
    final text = '${notification.title} ${notification.content}'.toLowerCase();
    return text.contains('rời vùng an toàn') ||
        text.contains('rời khỏi vùng an toàn') ||
        text.contains('roi khoi vung an toan');
  }

  /// Bat thong bao he thong cho cac canh bao roi vung an toan MOI khi app dang
  /// chay. Neu BE da gui push FCM thi 2 thong bao trung tag se gop lam 1.
  void _alertNewSafeZoneExits(List<AppNotification> notifications) {
    var maxId = _lastSeenNotificationId ?? 0;
    for (final notification in notifications) {
      if (notification.id > maxId) maxId = notification.id;
    }

    final baseline = _lastSeenNotificationId;
    _lastSeenNotificationId = maxId;
    if (baseline == null) {
      return;
    }

    final now = DateTime.now();
    for (final notification in notifications) {
      if (notification.id <= baseline ||
          !_isSafeZoneExitNotification(notification)) {
        continue;
      }
      final createdAt = notification.createdAt;
      if (createdAt != null && now.difference(createdAt) > _alertMaxAge) {
        continue;
      }
      unawaited(
        PushNotificationService.instance.showNotificationAlert(
          notificationId: notification.id,
          title: notification.title,
          body: notification.content,
        ),
      );
    }
  }

  void _scheduleRefresh() {
    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = Timer(const Duration(milliseconds: 400), () {
      refresh();
    });
  }

  Future<void> disposeController() async {
    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    _lastSeenNotificationId = null;
    _started = false;
  }

  @override
  void dispose() {
    unawaited(disposeController());
    super.dispose();
  }
}
