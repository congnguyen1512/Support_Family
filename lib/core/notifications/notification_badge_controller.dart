import 'dart:async';

import 'package:family_guard/core/realtime/supabase_realtime_client.dart';
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
    _started = false;
  }

  @override
  void dispose() {
    unawaited(disposeController());
    super.dispose();
  }
}
