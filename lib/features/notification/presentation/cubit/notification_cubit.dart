import 'dart:async';

import 'package:family_guard/core/network/network_error_mapper.dart';
import 'package:family_guard/core/realtime/supabase_realtime_client.dart';
import 'package:family_guard/features/notification/domain/entities/app_notification.dart';
import 'package:family_guard/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:family_guard/features/notification/domain/usecases/respond_notification_usecase.dart';
import 'package:family_guard/features/notification/presentation/cubit/notification_state.dart';
import 'package:flutter/foundation.dart';

class NotificationCubit extends ChangeNotifier {
  NotificationCubit({
    required GetNotificationsUseCase getNotificationsUseCase,
    required RespondNotificationUseCase respondNotificationUseCase,
    required SupabaseRealtimeClient realtimeClient,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _respondNotificationUseCase = respondNotificationUseCase,
       _realtimeClient = realtimeClient;

  final GetNotificationsUseCase _getNotificationsUseCase;
  final RespondNotificationUseCase _respondNotificationUseCase;
  final SupabaseRealtimeClient _realtimeClient;

  RealtimeWatchSubscription? _realtimeSubscription;
  Timer? _realtimeRefreshDebounce;
  Timer? _pollingTimer;
  bool _startingRealtime = false;
  bool _isDisposed = false;

  NotificationState _state = const NotificationState();
  NotificationState get state => _state;

  void _safeNotify() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  Future<List<AppNotification>> loadNotifications({
    bool showLoader = true,
  }) async {
    if (showLoader || _state.notifications.isEmpty) {
      _state = _state.copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
      );
      _safeNotify();
    }

    try {
      final notifications = await _getNotificationsUseCase();
      _state = _state.copyWith(
        isLoading: false,
        clearError: true,
        notifications: notifications,
      );
      _safeNotify();
      return notifications;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      _safeNotify();
      return _state.notifications;
    }
  }

  Future<void> startRealtime() async {
    _pollingTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      loadNotifications(showLoader: false);
    });

    if (!_startingRealtime && _realtimeSubscription == null) {
      _startingRealtime = true;
      try {
        _realtimeSubscription = await _realtimeClient.watchNotifications(
          _scheduleRealtimeRefresh,
        );
      } finally {
        _startingRealtime = false;
      }
    }
  }

  Future<void> stopRealtime() async {
    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }

  void _scheduleRealtimeRefresh() {
    if (_isDisposed) {
      return;
    }
    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = Timer(const Duration(milliseconds: 400), () {
      if (_isDisposed) {
        return;
      }
      loadNotifications(showLoader: false);
    });
  }

  Future<AppNotification?> confirmNotification(int id) {
    return _respond(
      id: id,
      action: 'xacnhan',
      successMessage: 'Đã xác nhận thông báo.',
    );
  }

  Future<AppNotification?> cancelNotification(int id) {
    return _respond(
      id: id,
      action: 'huy',
      successMessage: 'Đã hủy thông báo.',
    );
  }

  Future<AppNotification?> _respond({
    required int id,
    required String action,
    required String successMessage,
  }) async {
    _state = _state.copyWith(
      isResponding: true,
      clearError: true,
      clearSuccess: true,
    );
    _safeNotify();

    try {
      final updated = await _respondNotificationUseCase(id: id, action: action);
      _state = _state.copyWith(
        isResponding: false,
        clearError: true,
        successMessage: successMessage,
        notifications: _state.notifications
            .map(
              (item) => item.id == id
                  ? item.copyWith(
                      title: updated.title,
                      content: updated.content,
                      processing: updated.processing,
                      uid: updated.uid,
                      relationshipId: updated.relationshipId,
                      createdAt: updated.createdAt,
                    )
                  : item,
            )
            .toList(),
      );
      _safeNotify();
      return updated;
    } catch (error) {
      _state = _state.copyWith(
        isResponding: false,
        errorMessage: mapNetworkErrorMessage(error),
      );
      _safeNotify();
      return null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _realtimeRefreshDebounce?.cancel();
    _pollingTimer?.cancel();
    final subscription = _realtimeSubscription;
    _realtimeSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
